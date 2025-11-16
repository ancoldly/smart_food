from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Address
from .serializers import AddressSerializer


# ===== GET ALL + CREATE =====
class AddressListCreateView(generics.ListCreateAPIView):
    serializer_class = AddressSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Address.objects.filter(
            user=self.request.user
        ).order_by("-is_default", "-id")

    # Flutter: createAddress()
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    # Flutter expects status 201
    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        response.status_code = status.HTTP_201_CREATED
        return response


# ===== GET ONE / UPDATE / DELETE =====
class AddressDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = AddressSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Address.objects.filter(user=self.request.user)

    # Flutter updateAddress() expects status 200 OK
    def update(self, request, *args, **kwargs):
        response = super().update(request, *args, **kwargs)
        response.status_code = status.HTTP_200_OK
        return response

    # Flutter deleteAddress() expects status 204 NO CONTENT
    def destroy(self, request, *args, **kwargs):
        super().destroy(request, *args, **kwargs)
        return Response(status=status.HTTP_204_NO_CONTENT)


# ===== SET DEFAULT =====
class SetDefaultAddressView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        try:
            address = Address.objects.get(pk=pk, user=request.user)

            # Clear old default
            Address.objects.filter(
                user=request.user,
                is_default=True
            ).update(is_default=False)

            # Set new default
            address.is_default = True
            address.save()

            return Response({
                "success": True,
                "message": "Đã đặt làm địa chỉ mặc định"
            }, status=status.HTTP_200_OK)

        except Address.DoesNotExist:
            return Response({
                "success": False,
                "message": "Không tìm thấy địa chỉ"
            }, status=status.HTTP_404_NOT_FOUND)
