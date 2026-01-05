from rest_framework import serializers

from products.serializers import ProductSerializer
from stores.models import Store
from .models import Cart, CartItem, CartItemOption


class CartItemOptionSerializer(serializers.ModelSerializer):
    option_group_id = serializers.SerializerMethodField()
    option_group_template_id = serializers.SerializerMethodField()

    class Meta:
        model = CartItemOption
        fields = [
            "id",
            "option",
            "option_template",
            "name",
            "price",
            "option_group_id",
            "option_group_template_id",
        ]
        read_only_fields = ["id", "option_group_id", "option_group_template_id"]

    def get_option_group_id(self, obj):
        return obj.option.option_group_id if obj.option else None

    def get_option_group_template_id(self, obj):
        return obj.option_template.option_group_template_id if obj.option_template else None


class CartItemSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)
    options = CartItemOptionSerializer(many=True, read_only=True)
    options_total = serializers.SerializerMethodField()
    line_total = serializers.SerializerMethodField()

    class Meta:
        model = CartItem
        fields = [
            "id",
            "product",
            "quantity",
            "unit_price",
            "options_total",
            "line_total",
            "note",
            "options",
        ]
        read_only_fields = ["id", "options_total", "line_total"]

    def get_options_total(self, obj):
        return obj.options_total

    def get_line_total(self, obj):
        return obj.line_total


class CartSerializer(serializers.ModelSerializer):
    items = CartItemSerializer(many=True, read_only=True)
    total = serializers.SerializerMethodField()

    class Meta:
        model = Cart
        fields = [
            "id",
            "store",
            "status",
            "items",
            "total",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "created_at", "updated_at", "status", "total"]

    def get_total(self, obj):
        return sum(item.line_total for item in obj.items.all())


class DraftCartSerializer(serializers.Serializer):
    cart_id = serializers.IntegerField()
    store_id = serializers.IntegerField()
    store_name = serializers.CharField()
    store_address = serializers.CharField(allow_blank=True)
    store_city = serializers.CharField(allow_blank=True)
    store_avatar = serializers.CharField(allow_blank=True)
    item_count = serializers.IntegerField()
    total = serializers.DecimalField(max_digits=14, decimal_places=2)
    store_vouchers = serializers.ListField(child=serializers.DictField(), required=False)
    store_latitude = serializers.FloatField(required=False, allow_null=True)
    store_longitude = serializers.FloatField(required=False, allow_null=True)
