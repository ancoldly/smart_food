from django.urls import path
from .views import (
    UserStoreDetailView,
    StoreCreateView,
    StoreDetailView,
    ToggleStoreStatusView,
    AdminStoreListView,
    ApproveStoreView,
    RejectStoreView,
    PublicStoreListView,
    StoreTagListCreateView,
    StoreTagDetailView,
    FavoriteStoreListToggleView,
    StoreOperatingHourListView,
    StoreOperatingHourDetailView,
    StoreVoucherListCreateView,
    StoreVoucherDetailView,
    StoreCampaignListCreateView,
    StoreCampaignDetailView,
    store_campaign_impression,
    store_campaign_click,
)

urlpatterns = [
    # USER APIs
    path("me/", UserStoreDetailView.as_view(), name="user-store"),
    path("create/", StoreCreateView.as_view(), name="store-create"),
    path("<int:pk>/", StoreDetailView.as_view(), name="store-detail"),
    path("<int:pk>/toggle/", ToggleStoreStatusView.as_view(), name="store-toggle"),
    path("hours/", StoreOperatingHourListView.as_view(), name="store-hours"),
    path("hours/<int:pk>/", StoreOperatingHourDetailView.as_view(), name="store-hour-detail"),
    path("vouchers/", StoreVoucherListCreateView.as_view(), name="store-vouchers"),
    path("vouchers/<int:pk>/", StoreVoucherDetailView.as_view(), name="store-voucher-detail"),
    path("campaigns/", StoreCampaignListCreateView.as_view(), name="store-campaigns"),
    path("campaigns/<int:pk>/", StoreCampaignDetailView.as_view(), name="store-campaign-detail"),
    path("campaigns/<int:pk>/impression/", store_campaign_impression, name="store-campaign-impression"),
    path("campaigns/<int:pk>/click/", store_campaign_click, name="store-campaign-click"),

    # Store tags
    path("tags/", StoreTagListCreateView.as_view(), name="store-tags"),
    path("tags/<int:pk>/", StoreTagDetailView.as_view(), name="store-tag-detail"),
    path("favorites/", FavoriteStoreListToggleView.as_view(), name="store-favorite-toggle"),

    # ADMIN APIs
    path("admin/all/", AdminStoreListView.as_view(), name="admin-store-list"),
    path("admin/<int:pk>/approve/", ApproveStoreView.as_view(), name="store-approve"),
    path("admin/<int:pk>/reject/", RejectStoreView.as_view(), name="store-reject"),

    # Public
    path("public/", PublicStoreListView.as_view(), name="store-public"),
]
