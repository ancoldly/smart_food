from django.urls import path
from .views import ChangePasswordView, RegisterView, EmailLoginView, CurrentUserView, UpdateProfileView
from rest_framework_simplejwt.views import TokenRefreshView # type: ignore
from rest_framework_simplejwt.views import TokenBlacklistView # type: ignore



urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', EmailLoginView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('logout/', TokenBlacklistView.as_view(), name='token_blacklist'),
    path('me/', CurrentUserView.as_view(), name='current_user'),
    path('me/update/', UpdateProfileView.as_view(), name='update_profile'),
    path('me/change-password/', ChangePasswordView.as_view(), name='change_password'),
]
