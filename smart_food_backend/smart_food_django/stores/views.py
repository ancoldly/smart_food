from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.views import APIView

from django.shortcuts import get_object_or_404

from users.permissions import IsAdminRole
from .models import Store
from .serializers import StoreSerializer

class AdminStoreListView(APIView):
    permission_classes = [IsAdminRole]

    def get(self, request):
        stores = Store.objects.all().order_by("-created_at")
        serializer = StoreSerializer(stores, many=True)
        return Response(serializer.data, status=200)



# ======================================================
#   LIST STORES (OF CURRENT USER) + CREATE STORE
# ======================================================
class StoreListCreateView(generics.ListCreateAPIView):
    serializer_class = StoreSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get_queryset(self):
        return Store.objects.filter(
            user=self.request.user
        ).order_by("-created_at")

    def perform_create(self, serializer):
        serializer.save(user=self.request.user, status=1)  # 1 = pending

    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        response.status_code = status.HTTP_201_CREATED
        return response


# ======================================================
#   GET ONE STORE / UPDATE / DELETE
# ======================================================
class StoreDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = StoreSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Store.objects.filter(user=self.request.user)

    # UPDATE
    def update(self, request, *args, **kwargs):
        response = super().update(request, *args, **kwargs)
        response.status_code = status.HTTP_200_OK
        return response

    # DELETE
    def destroy(self, request, *args, **kwargs):
        super().destroy(request, *args, **kwargs)
        return Response(status=status.HTTP_204_NO_CONTENT)


# ======================================================
#   ADMIN APPROVE STORE
# ======================================================
class ApproveStoreView(APIView):
    permission_classes = [IsAdminRole]

    def post(self, request, pk):
        store = get_object_or_404(Store, pk=pk)

        store.status = 2  # Approved
        store.save()

        return Response({
            "success": True,
            "message": "Đã duyệt cửa hàng",
        }, status=status.HTTP_200_OK)


# ======================================================
#   ADMIN REJECT STORE
# ======================================================
class RejectStoreView(APIView):
    permission_classes = [IsAdminRole]

    def post(self, request, pk):
        store = get_object_or_404(Store, pk=pk)

        store.status = 3  # Rejected
        store.save()

        return Response({
            "success": True,
            "message": "Đã từ chối cửa hàng",
        }, status=status.HTTP_200_OK)


# ======================================================
#   MERCHANT OPEN/CLOSE STORE (ACTIVE SWITCH)
# ======================================================
class ToggleStoreStatusView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        store = get_object_or_404(Store, pk=pk, user=request.user)

        # status: 2 = approved but closed, 4 = active/open
        if store.status == 4:
            store.status = 2   # Close store
            msg = "Đã đóng cửa hàng"
        else:
            store.status = 4   # Open store
            msg = "Đã mở cửa hàng"

        store.save()

        return Response({
            "success": True,
            "message": msg,
        }, status=status.HTTP_200_OK)
