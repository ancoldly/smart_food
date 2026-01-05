from django.urls import path
from .views import (
    AdminUserListView,
    AdminStatsView,
    ChangePasswordView,
    CheckRoleView,
    RegisterView,
    EmailLoginView,
    CurrentUserView,
    UpdateProfileView,
)
from rest_framework_simplejwt.views import TokenRefreshView # type: ignore
from rest_framework_simplejwt.views import TokenBlacklistView # type: ignore



urlpatterns = [

    # ADMIN APIs
    path("admin/users/", AdminUserListView.as_view(), name="admin_user_list"),
    path("admin/stats/", AdminStatsView.as_view(), name="admin_stats"),
    # USER APIs
    path("check-role/", CheckRoleView.as_view(), name="check_role"),
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', EmailLoginView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('logout/', TokenBlacklistView.as_view(), name='token_blacklist'),
    path('me/', CurrentUserView.as_view(), name='current_user'),
    path('me/update/', UpdateProfileView.as_view(), name='update_profile'),
    path('me/change-password/', ChangePasswordView.as_view(), name='change_password'),
]
