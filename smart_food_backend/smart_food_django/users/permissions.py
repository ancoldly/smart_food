from rest_framework.permissions import BasePermission

class IsAdminRole(BasePermission):
    """
    Chỉ cho phép user có role = 'admin'
    """
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == "admin"
