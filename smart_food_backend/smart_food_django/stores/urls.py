from django.urls import path
from .views import (
    StoreListCreateView,
    StoreDetailView,
    ApproveStoreView,
    RejectStoreView,
    ToggleStoreStatusView,
    AdminStoreListView,
)

urlpatterns = [
    # Merchant APIs
    path("", StoreListCreateView.as_view(), name="store-list-create"),
    path("<int:pk>/", StoreDetailView.as_view(), name="store-detail"),
    path("<int:pk>/toggle/", ToggleStoreStatusView.as_view(), name="store-toggle"),

    # Admin APIs
    path("admin/all/", AdminStoreListView.as_view(), name="admin-store-list"),
    path("<int:pk>/approve/", ApproveStoreView.as_view(), name="store-approve"),
    path("<int:pk>/reject/", RejectStoreView.as_view(), name="store-reject"),
]
