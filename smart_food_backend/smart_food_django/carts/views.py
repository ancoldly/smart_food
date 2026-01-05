from typing import List, Dict

from django.db import transaction
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from products.models import Product, Option, OptionTemplate, ProductOptionGroup
from stores.models import Store
from stores.serializers import StoreVoucherSerializer
from .models import Cart, CartItem, CartItemOption
from .serializers import CartSerializer, DraftCartSerializer


def _get_or_create_cart(user, store: Store) -> Cart:
    cart, _ = Cart.objects.get_or_create(
        user=user, store=store, status="open"
    )
    return cart


def _options_key(options_payload: List[Dict]) -> str:
    """
    Create a deterministic key for selected options to find existing item.
    options_payload is list of dicts with option_id / option_template_id.
    """
    normalized = []
    for o in options_payload:
        option_id = o.get("option_id")
        option_template_id = o.get("option_template_id")
        normalized.append(
            f"opt:{option_id}" if option_id else f"tpl:{option_template_id}"
        )
    normalized.sort()
    return "|".join(normalized)


class CartView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        store_id = request.query_params.get("store")
        if not store_id:
            return Response({"detail": "store is required"}, status=400)
        store = Store.objects.filter(id=store_id).first()
        if not store:
            return Response({"detail": "Store not found"}, status=404)

        cart = _get_or_create_cart(request.user, store)
        data = CartSerializer(cart, context={"request": request}).data
        return Response(data, status=200)


class AddItemView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @transaction.atomic
    def post(self, request):
        user = request.user
        store_id = request.data.get("store_id")
        product_id = request.data.get("product_id")
        quantity = int(request.data.get("quantity") or 1)
        options_payload = request.data.get("options") or []
        note = request.data.get("note") or ""

        if not store_id or not product_id:
            return Response({"detail": "store_id and product_id are required"}, status=400)

        try:
            product = Product.objects.select_related("store").get(id=product_id, is_available=True)
        except Product.DoesNotExist:
            return Response({"detail": "Product not found"}, status=404)

        if product.store_id != int(store_id):
            return Response({"detail": "Product does not belong to store"}, status=400)

        store = product.store
        cart = _get_or_create_cart(user, store)

        # Validate options
        validated_options = []
        for opt in options_payload:
            option_id = opt.get("option_id")
            option_tpl_id = opt.get("option_template_id")

            if option_id:
                try:
                    option_obj = Option.objects.select_related("option_group", "option_group__product").get(
                        id=option_id
                    )
                except Option.DoesNotExist:
                    return Response({"detail": f"Option {option_id} not found"}, status=404)
                if option_obj.option_group.product_id != product.id:
                    return Response({"detail": "Option does not belong to product"}, status=400)
                validated_options.append(
                    {
                        "option": option_obj,
                        "name": option_obj.name,
                        "price": option_obj.price,
                    }
                )
            elif option_tpl_id:
                try:
                    tpl_obj = OptionTemplate.objects.select_related("option_group_template").get(
                        id=option_tpl_id
                    )
                except OptionTemplate.DoesNotExist:
                    return Response({"detail": f"Option template {option_tpl_id} not found"}, status=404)

                # ensure this template is linked to product
                if not ProductOptionGroup.objects.filter(
                    product=product, option_group_template=tpl_obj.option_group_template
                ).exists():
                    return Response({"detail": "Template option not linked to product"}, status=400)

                validated_options.append(
                    {
                        "option_template": tpl_obj,
                        "name": tpl_obj.name,
                        "price": tpl_obj.price,
                    }
                )
            else:
                return Response({"detail": "option_id or option_template_id required"}, status=400)

        # Try to find existing item with same option set
        options_key = _options_key(options_payload)
        existing_item = None
        for item in cart.items.select_related("product").prefetch_related("options").all():
            if item.product_id != product.id:
                continue
            existing_keys = _options_key([
                {
                    "option_id": opt.option_id,
                    "option_template_id": opt.option_template_id,
                }
                for opt in item.options.all()
            ])
            if existing_keys == options_key:
                existing_item = item
                break

        unit_price = product.discount_price or product.price

        if existing_item:
            existing_item.quantity += quantity
            existing_item.unit_price = unit_price
            existing_item.note = note
            existing_item.save()
        else:
            existing_item = CartItem.objects.create(
                cart=cart,
                product=product,
                quantity=quantity,
                unit_price=unit_price,
                note=note,
            )
            CartItemOption.objects.bulk_create([
                CartItemOption(
                    cart_item=existing_item,
                    option=opt.get("option"),
                    option_template=opt.get("option_template"),
                    name=opt["name"],
                    price=opt["price"],
                )
                for opt in validated_options
            ])

        cart.refresh_from_db()
        data = CartSerializer(cart, context={"request": request}).data
        return Response(data, status=200)


class UpdateItemView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @transaction.atomic
    def patch(self, request, item_id):
        quantity = int(request.data.get("quantity") or 1)
        try:
            item = CartItem.objects.select_related("cart", "cart__user").get(id=item_id)
        except CartItem.DoesNotExist:
            return Response({"detail": "Item not found"}, status=404)

        if item.cart.user != request.user:
            return Response({"detail": "Forbidden"}, status=403)

        if quantity <= 0:
            cart = item.cart
            item.delete()
            cart.refresh_from_db()
            data = CartSerializer(cart, context={"request": request}).data
            return Response(data, status=200)

        item.quantity = quantity
        item.save()
        cart = item.cart
        cart.refresh_from_db()
        data = CartSerializer(cart, context={"request": request}).data
        return Response(data, status=200)


class DeleteItemView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @transaction.atomic
    def delete(self, request, item_id):
        try:
            item = CartItem.objects.select_related("cart", "cart__user").get(id=item_id)
        except CartItem.DoesNotExist:
            return Response({"detail": "Item not found"}, status=404)

        if item.cart.user != request.user:
            return Response({"detail": "Forbidden"}, status=403)

        cart = item.cart
        item.delete()
        cart.refresh_from_db()
        data = CartSerializer(cart, context={"request": request}).data
        return Response(data, status=200)


class DraftCartsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        carts = (
            Cart.objects.filter(user=request.user, status="open")
            .prefetch_related("items", "store")
            .all()
        )
        result = []
        for c in carts:
            items_count = c.items.count()
            if items_count == 0:
                continue
            total = sum(item.line_total for item in c.items.all())
            avatar_url = ""
            if c.store.avatar_image:
                if request and hasattr(request, "build_absolute_uri"):
                    avatar_url = request.build_absolute_uri(c.store.avatar_image.url)
                else:
                    avatar_url = c.store.avatar_image.url
            vouchers = StoreVoucherSerializer(
                c.store.store_vouchers.all(), many=True
            ).data
            result.append(
                {
                    "cart_id": c.id,
                    "store_id": c.store_id,
                    "store_name": c.store.store_name,
                    "store_address": c.store.address,
                    "store_city": c.store.city,
                    "store_avatar": avatar_url,
                    "store_latitude": c.store.latitude,
                    "store_longitude": c.store.longitude,
                    "store_vouchers": vouchers,
                    "item_count": items_count,
                    "total": total,
                }
            )
        serializer = DraftCartSerializer(result, many=True)
        return Response(serializer.data, status=200)
