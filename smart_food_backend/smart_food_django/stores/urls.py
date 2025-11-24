from django.urls import path
from .views import (
    UserStoreDetailView,
    StoreCreateView,
    StoreDetailView,
    ToggleStoreStatusView,
    AdminStoreListView,
    ApproveStoreView,
    RejectStoreView,
)

urlpatterns = [

    # USER APIs
    path("me/", UserStoreDetailView.as_view(), name="user-store"),               # GET my store
    path("create/", StoreCreateView.as_view(), name="store-create"),            # POST create store
    path("<int:pk>/", StoreDetailView.as_view(), name="store-detail"),          # GET/PUT/PATCH/DELETE
    path("<int:pk>/toggle/", ToggleStoreStatusView.as_view(), name="store-toggle"),

    # ADMIN APIs
    path("admin/all/", AdminStoreListView.as_view(), name="admin-store-list"),
    path("admin/<int:pk>/approve/", ApproveStoreView.as_view(), name="store-approve"),
    path("admin/<int:pk>/reject/", RejectStoreView.as_view(), name="store-reject"),
]
