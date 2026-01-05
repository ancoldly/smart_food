from rest_framework import serializers
from .models import Order, OrderItem, OrderItemOption, Review


class OrderItemOptionSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderItemOption
        fields = ["id", "name", "price"]


class OrderItemSerializer(serializers.ModelSerializer):
    product_image = serializers.SerializerMethodField()
    product_id = serializers.IntegerField(source="product.id", read_only=True)

    options = OrderItemOptionSerializer(many=True, read_only=True)

    class Meta:
        model = OrderItem
        fields = [
            "id",
            "product",
            "product_id",
            "product_name",
            "quantity",
            "unit_price",
            "line_total",
            "product_image",
            "options",
        ]

    def get_product_image(self, obj):
        if obj.product and obj.product.image:
            try:
                return obj.product.image.url
            except Exception:
                return str(obj.product.image)
        return ""


class ReviewSerializer(serializers.ModelSerializer):
    store_name = serializers.SerializerMethodField()
    product_name = serializers.SerializerMethodField()
    user_name = serializers.SerializerMethodField()

    class Meta:
        model = Review
        fields = [
            "id",
            "order",
            "store",
            "store_name",
            "product",
            "product_name",
            "user_name",
            "rating",
            "comment",
            "reply_comment",
            "reply_at",
            "created_at",
        ]
        read_only_fields = ["id", "created_at"]

    def get_store_name(self, obj):
        return getattr(obj.store, "store_name", "") if obj.store else ""

    def get_product_name(self, obj):
        return getattr(obj.product, "name", "") if obj.product else ""

    def get_user_name(self, obj):
        return getattr(obj.user, "full_name", "") if obj.user else ""


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    store_name = serializers.SerializerMethodField()
    store_avatar = serializers.SerializerMethodField()
    store_address = serializers.SerializerMethodField()
    item_count = serializers.SerializerMethodField()
    shipper_id = serializers.IntegerField(source="shipper.id", read_only=True)
    shipper_name = serializers.SerializerMethodField()
    store_latitude = serializers.SerializerMethodField()
    store_longitude = serializers.SerializerMethodField()
    dest_latitude = serializers.SerializerMethodField()
    dest_longitude = serializers.SerializerMethodField()

    class Meta:
        model = Order
        fields = [
            "id",
            "user",
            "store",
            "store_name",
            "store_avatar",
            "store_address",
            "address_line",
            "receiver_name",
            "receiver_phone",
            "status",
            "payment_method",
            "payment_status",
            "subtotal",
            "shipping_fee",
            "discount",
            "total",
            "app_voucher",
            "store_voucher",
            "shipper_id",
            "shipper_name",
            "merchant_earning",
            "shipper_earning",
            "created_at",
            "items",
            "item_count",
            "store_latitude",
            "store_longitude",
            "dest_latitude",
            "dest_longitude",
        ]
        read_only_fields = ["user", "created_at", "status", "payment_status"]

    def get_store_name(self, obj):
        return getattr(obj.store, "store_name", "") if obj.store else ""

    def get_store_avatar(self, obj):
        if obj.store and obj.store.avatar_image:
            try:
                return obj.store.avatar_image.url
            except Exception:
                return str(obj.store.avatar_image)
        return ""

    def get_store_address(self, obj):
        return getattr(obj.store, "address", "") if obj.store else ""

    def get_item_count(self, obj):
        return obj.items.count()

    def get_shipper_name(self, obj):
        if obj.shipper:
            return obj.shipper.full_name
        return ""

    def get_store_latitude(self, obj):
        return getattr(obj.store, "latitude", None) if obj.store else None

    def get_store_longitude(self, obj):
        return getattr(obj.store, "longitude", None) if obj.store else None

    def get_dest_latitude(self, obj):
        return getattr(obj, "address_latitude", None) if hasattr(obj, "address_latitude") else None

    def get_dest_longitude(self, obj):
        return getattr(obj, "address_longitude", None) if hasattr(obj, "address_longitude") else None
