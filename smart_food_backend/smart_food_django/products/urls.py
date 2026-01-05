from django.urls import path
from .views import (
    ProductListCreateView,
    ProductDetailView,
    AdminProductListView,
    PublicProductByStoreView,
    OptionGroupListCreateView,
    OptionGroupDetailView,
    OptionListCreateView,
    OptionDetailView,
    OptionGroupTemplateListCreateView,
    OptionGroupTemplateDetailView,
    OptionTemplateListCreateView,
    OptionTemplateDetailView,
    ProductOptionGroupListCreateView,
    ProductOptionGroupDetailView,
    PublicOptionGroupByProductView,
    PublicProductOptionsView,
)

urlpatterns = [
    # Products
    path("", ProductListCreateView.as_view(), name="product-list-create"),
    path("<int:pk>/", ProductDetailView.as_view(), name="product-detail"),
    path("admin/all/", AdminProductListView.as_view(), name="admin-product-list"),
    path("public/<int:store_id>/", PublicProductByStoreView.as_view(), name="product-public-by-store"),
    path("public/<int:product_id>/options/", PublicProductOptionsView.as_view(), name="product-options-public"),
    path("public/<int:product_id>/option-groups/", PublicOptionGroupByProductView.as_view(), name="option-group-public-by-product"),

    # Option groups
    path("option-groups/", OptionGroupListCreateView.as_view(), name="option-group-list-create"),
    path("option-groups/<int:pk>/", OptionGroupDetailView.as_view(), name="option-group-detail"),

    # Options
    path("options/", OptionListCreateView.as_view(), name="option-list-create"),
    path("options/<int:pk>/", OptionDetailView.as_view(), name="option-detail"),

    # Templates
    path("templates/option-groups/", OptionGroupTemplateListCreateView.as_view(), name="option-group-template-list"),
    path("templates/option-groups/<int:pk>/", OptionGroupTemplateDetailView.as_view(), name="option-group-template-detail"),
    path("templates/options/", OptionTemplateListCreateView.as_view(), name="option-template-list"),
    path("templates/options/<int:pk>/", OptionTemplateDetailView.as_view(), name="option-template-detail"),

    # Product-option-group mapping
    path("product-option-groups/", ProductOptionGroupListCreateView.as_view(), name="product-option-group-list"),
    path("product-option-groups/<int:pk>/", ProductOptionGroupDetailView.as_view(), name="product-option-group-detail"),
]
