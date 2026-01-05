from django.urls import path
from .views import CartView, AddItemView, UpdateItemView, DeleteItemView, DraftCartsView

urlpatterns = [
    path("", CartView.as_view(), name="cart-detail"),
    path("add-item/", AddItemView.as_view(), name="cart-add-item"),
    path("items/<int:item_id>/", UpdateItemView.as_view(), name="cart-update-item"),
    path("items/<int:item_id>/delete/", DeleteItemView.as_view(), name="cart-delete-item"),
    path("drafts/", DraftCartsView.as_view(), name="cart-drafts"),
]
