from django.urls import path
from .views import (
    CategoryListCreateView,
    CategoryDetailView,
    PublicCategoryByStoreView,
)

urlpatterns = [
    # Merchant routes
    path("", CategoryListCreateView.as_view(), name="category-list-create"),
    path("<int:pk>/", CategoryDetailView.as_view(), name="category-detail"),

    # Public
    path("public/<int:store_id>/", PublicCategoryByStoreView.as_view(), name="category-public-by-store"),
]
