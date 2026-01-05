from django.urls import path
from .views import (
    ShipperStatusToggleView,
    ShipperRegisterView,
    ShipperMeView,
    ShipperAdminListView,
    ShipperAdminStatusView,
    ShipperApproveView,
    ShipperRejectView,
    ShipperBanView,
    ShipperLocationUpdateView,
)

urlpatterns = [
    path("me/status/", ShipperStatusToggleView.as_view(), name="shipper-status-toggle"),
    path("me/location/", ShipperLocationUpdateView.as_view(), name="shipper-location"),
    path("register/", ShipperRegisterView.as_view(), name="shipper-register"),
    path("me/", ShipperMeView.as_view(), name="shipper-me"),
    path("admin/", ShipperAdminListView.as_view(), name="shipper-admin-list"),
    path(
        "admin/<int:pk>/",
        ShipperAdminStatusView.as_view(),
        name="shipper-admin-status",
    ),
    path("admin/<int:pk>/approve/", ShipperApproveView.as_view(), name="shipper-approve"),
    path("admin/<int:pk>/reject/", ShipperRejectView.as_view(), name="shipper-reject"),
    path("admin/<int:pk>/ban/", ShipperBanView.as_view(), name="shipper-ban"),
]


