from rest_framework import serializers
from django.utils.text import slugify
from .models import Store, StoreTag, FavoriteStore, StoreOperatingHour, StoreVoucher, StoreCampaign


class StoreOperatingHourSerializer(serializers.ModelSerializer):
    class Meta:
        model = StoreOperatingHour
        fields = "__all__"
        read_only_fields = ("id", "store", "created_at", "updated_at")

    def validate(self, attrs):
        is_closed = attrs.get("is_closed", False)
        open_time = attrs.get("open_time")
        close_time = attrs.get("close_time")

        instance = getattr(self, "instance", None)
        open_final = open_time or (instance.open_time if instance else None)
        close_final = close_time or (instance.close_time if instance else None)

        if not is_closed:
            if not open_final or not close_final:
                raise serializers.ValidationError(
                    "Cần nhập giờ mở và giờ đóng khi cửa hàng hoạt động."
                )
            if open_final == close_final:
                raise serializers.ValidationError("Giờ mở và đóng phải khác nhau.")
        return attrs


class StoreVoucherSerializer(serializers.ModelSerializer):
    class Meta:
        model = StoreVoucher
        fields = "__all__"
        read_only_fields = ("id", "store", "created_at", "updated_at", "used_count")

    def validate(self, attrs):
        start = attrs.get("start_date")
        end = attrs.get("end_date")
        if start and end and end < start:
            raise serializers.ValidationError("Ngày kết thúc phải sau ngày bắt đầu.")
        discount_type = attrs.get("discount_type", "percent")
        discount_value = attrs.get("discount_value")
        if discount_type == "percent" and discount_value and discount_value > 100:
            raise serializers.ValidationError("Giá trị phần trăm không quá 100%.")
        return attrs


class StoreCampaignSerializer(serializers.ModelSerializer):
    class Meta:
        model = StoreCampaign
        fields = "__all__"
        read_only_fields = ("id", "store", "impressions", "clicks", "created_at", "updated_at")

    def validate(self, attrs):
        start = attrs.get("start_date")
        end = attrs.get("end_date")
        if start and end and end < start:
            raise serializers.ValidationError("Ngày kết thúc phải sau ngày bắt đầu.")
        return attrs


class StoreSerializer(serializers.ModelSerializer):
    avatar_image = serializers.ImageField(required=False)
    background_image = serializers.ImageField(required=False)
    operating_hours = StoreOperatingHourSerializer(many=True, read_only=True)
    store_vouchers = StoreVoucherSerializer(many=True, read_only=True)
    campaigns = StoreCampaignSerializer(many=True, read_only=True)

    class Meta:
        model = Store
        fields = "__all__"
        read_only_fields = ("id", "user", "created_at", "updated_at")

    def to_representation(self, instance):
        rep = super().to_representation(instance)
        request = self.context.get("request")

        if instance.avatar_image:
            rep["avatar_image"] = request.build_absolute_uri(instance.avatar_image.url)

        if instance.background_image:
            rep["background_image"] = request.build_absolute_uri(instance.background_image.url)

        return rep


class StoreTagSerializer(serializers.ModelSerializer):
    class Meta:
        model = StoreTag
        fields = "__all__"
        read_only_fields = ("id", "store", "created_at", "updated_at")
        extra_kwargs = {"slug": {"required": False, "allow_blank": True}}

    def validate(self, attrs):
        name = attrs.get("name")
        slug = attrs.get("slug")
        if name and not slug:
            attrs["slug"] = slugify(name)
        return attrs


class FavoriteStoreSerializer(serializers.ModelSerializer):
    class Meta:
        model = FavoriteStore
        fields = ["id", "store", "created_at"]
        read_only_fields = ["id", "created_at"]
