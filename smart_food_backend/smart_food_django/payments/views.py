from email.feedparser import FeedParser
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from django.shortcuts import get_object_or_404

from .models import Payment
from .serializers import PaymentSerializer
from rest_framework.parsers import MultiPartParser, FormParser


# =====================================
#   GET ALL PAYMENT + CREATE PAYMENT
# =====================================
class PaymentListCreateView(generics.ListCreateAPIView):
    serializer_class = PaymentSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get_queryset(self):
        return Payment.objects.filter(user=self.request.user).order_by('-is_default','-id')

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
            return Response({
                "success": False,
                "message": "Không tìm thấy phương thức thanh toán"
            }, status=status.HTTP_404_NOT_FOUND)

        # Clear old defaults
        Payment.objects.filter(
            user=request.user,
            is_default=True
        ).update(is_default=False)

        # Set new default
        payment.is_default = True
        payment.save()

        return Response({
            "success": True,
            "message": "Đã đặt làm phương thức mặc định"
        }, status=status.HTTP_200_OK)
