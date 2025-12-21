from django.urls import path
from .views import (
    CategoryListCreateView,
    CategoryDetailView,
    AdminCategoryListView,
    PublicCategoryByStoreView,
)

urlpatterns = [
    # Merchant routes
    path("", CategoryListCreateView.as_view(), name="category-list-create"),
    path("<int:pk>/", CategoryDetailView.as_view(), name="category-detail"),

    # Admin routes
    path("admin/all/", AdminCategoryListView.as_view(), name="admin-category-list"),

    # Public
    path("public/<int:store_id>/", PublicCategoryByStoreView.as_view(), name="category-public-by-store"),
]
