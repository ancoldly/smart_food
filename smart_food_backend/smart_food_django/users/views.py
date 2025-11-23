from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import User
from .serializers import ChangePasswordSerializer, RegisterSerializer, UpdateProfileSerializer
from rest_framework_simplejwt.views import TokenObtainPairView # type: ignore
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer # type: ignore
from rest_framework import permissions, status

from rest_framework.permissions import IsAuthenticated

class CheckRoleView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response({
            "id": request.user.id,
            "email": request.user.email,
            "role": request.user.role,
        })

# ======== API ĐĂNG KÝ ========
class RegisterView(generics.CreateAPIView):
    """
    API cho phép người dùng đăng ký tài khoản mới.
    Không yêu cầu token.
    """
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]


# ======== API ĐĂNG NHẬP (EMAIL + PASSWORD) ========
class EmailTokenObtainPairSerializer(TokenObtainPairSerializer):
    """
    Custom serializer để login bằng email thay vì username.
    """
    username_field = 'email'


class EmailLoginView(TokenObtainPairView):
    """
    API đăng nhập, trả về JWT access và refresh token.
    """
    serializer_class = EmailTokenObtainPairSerializer
    permission_classes = [permissions.AllowAny]


# ======== API LẤY THÔNG TIN USER HIỆN TẠI ========
class CurrentUserView(APIView):
    """
    Trả về thông tin người dùng hiện tại (dựa trên token).
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        data = {
            "id": user.id,
            "email": user.email,
            "username": user.username,
            "full_name": user.full_name,
            "phone": user.phone,
            "role": user.role,
            "avatar": request.build_absolute_uri(user.avatar.url) if user.avatar else None,
            "created_at": user.created_at,
        }
        return Response(data)

class UpdateProfileView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def put(self, request):
        user = request.user

        # xử lý avatar file
        if "avatar" in request.FILES:
            user.avatar = request.FILES["avatar"]

        serializer = UpdateProfileSerializer(
            user,
            data=request.data,
            partial=True
        )

        if serializer.is_valid():
            serializer.save()
            user.save()     # lưu avatar nếu có
            return Response(serializer.data, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)



# ==========================================
# Đổi mật khẩu
# ==========================================
class ChangePasswordView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def put(self, request):
        serializer = ChangePasswordSerializer(
            data=request.data,
            context={"request": request}
        )

        if not serializer.is_valid():
            return Response({
                "success": False,
                "message": serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)

        user = request.user
        user.set_password(serializer.validated_data["new_password"])
        user.save()

        return Response({
            "success": True,
            "message": "Đổi mật khẩu thành công"
        }, status=status.HTTP_200_OK)

