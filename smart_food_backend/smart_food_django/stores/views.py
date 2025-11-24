from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.views import APIView

from django.shortcuts import get_object_or_404

from users.permissions import IsAdminRole

from .models import Store
from .serializers import StoreSerializer


# ==========================================
#   USER: GET MY STORE (ONLY 1)
# ==========================================
class UserStoreDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        store = Store.objects.filter(user=request.user).first()

        if not store:
            return Response(None, status=200)

        serializer = StoreSerializer(store)
        return Response(serializer.data, status=200)


# ==========================================
#   USER: CREATE STORE (ONLY 1)
# ==========================================
class StoreCreateView(generics.CreateAPIView):
    serializer_class = StoreSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user, status=1)  # 1 = pending

    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        response.status_code = status.HTTP_201_CREATED
        return response


# ==========================================
#   USER: UPDATE / DELETE STORE
# ==========================================
class StoreDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = StoreSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Store.objects.filter(user=self.request.user)

    def update(self, request, *args, **kwargs):
        response = super().update(request, *args, **kwargs)
        response.status_code = status.HTTP_200_OK
        return response

    def destroy(self, request, *args, **kwargs):
        super().destroy(request, *args, **kwargs)
        return Response(status=status.HTTP_204_NO_CONTENT)


# ==========================================
#   USER: TOGGLE STORE STATUS (OPEN/CLOSE)
# ==========================================
class ToggleStoreStatusView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        store = get_object_or_404(Store, pk=pk, user=request.user)

        if store.status == 4:       # open → close
            store.status = 2
            msg = "Đã đóng cửa hàng"
        else:                      # close → open
            store.status = 4
            msg = "Đã mở cửa hàng"

        store.save()

        return Response({"success": True, "message": msg}, status=200)


# ==========================================
#   ADMIN: LIST ALL STORES
# ==========================================
class AdminStoreListView(APIView):
    permission_classes = [IsAdminRole]

    def get(self, request):
        stores = Store.objects.all().order_by("-created_at")
        serializer = StoreSerializer(stores, many=True)
        return Response(serializer.data, status=200)


# ==========================================
#   ADMIN: APPROVE STORE
# ==========================================
class ApproveStoreView(APIView):
    permission_classes = [IsAdminRole]

    def post(self, request, pk):
        store = get_object_or_404(Store, pk=pk)
        store.status = 2  # Approved but closed
        store.save()

        return Response({"success": True, "message": "Đã duyệt cửa hàng"}, status=200)


# ==========================================
#   ADMIN: REJECT STORE
# ==========================================
class RejectStoreView(APIView):
    permission_classes = [IsAdminRole]

    def post(self, request, pk):
        store = get_object_or_404(Store, pk=pk)
        store.status = 3  # Rejected
        store.save()

        return Response({"success": True, "message": "Đã từ chối cửa hàng"}, status=200)
