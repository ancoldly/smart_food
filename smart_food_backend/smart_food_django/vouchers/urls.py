from django.urls import path

from .views import (
    AdminVoucherListCreateView,
    AdminVoucherDetailView,
    PublicVoucherListView,
)

urlpatterns = [
    path("admin/", AdminVoucherListCreateView.as_view(), name="admin-vouchers"),
    path("admin/<int:pk>/", AdminVoucherDetailView.as_view(), name="admin-voucher-detail"),
    path("public/", PublicVoucherListView.as_view(), name="public-vouchers"),
]
