from decimal import Decimal
from rest_framework import generics, permissions, status
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Payment, Wallet, WalletTransaction
from .serializers import PaymentSerializer, WalletSerializer, WalletTransactionSerializer


# =====================================
#   GET ALL PAYMENT + CREATE PAYMENT
# =====================================
class PaymentListCreateView(generics.ListCreateAPIView):
    serializer_class = PaymentSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get_queryset(self):
        return Payment.objects.filter(user=self.request.user).order_by("-is_default", "-id")

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    # Flutter expects 201 CREATED
    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        response.status_code = status.HTTP_201_CREATED
        return response


# =====================================
#   GET ONE / UPDATE / DELETE PAYMENT
# =====================================
class PaymentDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = PaymentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Payment.objects.filter(user=self.request.user)

    # Flutter expects update = 200 OK
    def update(self, request, *args, **kwargs):
        response = super().update(request, *args, **kwargs)
        response.status_code = status.HTTP_200_OK
        return response

    # Flutter expects delete = 204 NO CONTENT
    def destroy(self, request, *args, **kwargs):
        super().destroy(request, *args, **kwargs)
        return Response(status=status.HTTP_204_NO_CONTENT)


# =====================================
#   SET PAYMENT DEFAULT
# =====================================
class SetDefaultPaymentView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        payment = Payment.objects.filter(id=pk, user=request.user).first()

        if not payment:
            return Response(
                {
                    "success": False,
                    "message": "Không tìm thấy phương thức thanh toán",
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        # Clear old defaults
        Payment.objects.filter(user=request.user, is_default=True).update(is_default=False)

        # Set new default
        payment.is_default = True
        payment.save()

        return Response(
            {
                "success": True,
                "message": "Đã đặt làm phương thức mặc định",
            },
            status=status.HTTP_200_OK,
        )


# =====================================
#   WALLET (MERCHANT / SHIPPER)
# =====================================
class WalletView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def _get_role(self, role: str):
        role = (role or "").lower()
        if role not in ("merchant", "shipper"):
            return None
        return role

    def _get_wallet(self, user, role: str):
        role = self._get_role(role)
        if not role:
            return None
        wallet, _ = Wallet.objects.get_or_create(user=user, role=role)
        return wallet

    def get(self, request, role: str):
        wallet = self._get_wallet(request.user, role)
        if not wallet:
            return Response({"success": False, "message": "Role không hợp lệ"}, status=400)

        data = {
            "wallet": WalletSerializer(wallet).data,
            "transactions": WalletTransactionSerializer(wallet.transactions.all(), many=True).data,
        }
        return Response(data, status=200)

    def post(self, request, role: str):
        wallet = self._get_wallet(request.user, role)
        if not wallet:
            return Response({"success": False, "message": "Role không hợp lệ"}, status=400)

        action = (request.data.get("action") or "").lower()
        try:
            amount = Decimal(str(request.data.get("amount", 0)))
        except Exception:
            amount = Decimal("0")

        if action not in ("topup", "withdraw"):
            return Response({"success": False, "message": "Hành động không hợp lệ"}, status=400)

        if amount <= 0:
            return Response({"success": False, "message": "Số tiền không hợp lệ"}, status=400)

        note = request.data.get("note") or ("Nạp tiền" if action == "topup" else "Rút tiền")

        if action == "withdraw" and wallet.balance < amount:
            return Response({"success": False, "message": "Số dư không đủ để rút"}, status=400)

        # Update balance
        wallet.balance = wallet.balance + amount if action == "topup" else wallet.balance - amount
        wallet.save()

        WalletTransaction.objects.create(
            wallet=wallet,
            amount=amount if action == "topup" else -amount,
            type=action,
            note=note,
        )

        data = {
            "wallet": WalletSerializer(wallet).data,
            "transactions": WalletTransactionSerializer(wallet.transactions.all(), many=True).data,
        }
        return Response(data, status=200)
