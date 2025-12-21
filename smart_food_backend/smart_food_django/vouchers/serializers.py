from rest_framework import serializers
from django.utils import timezone

from .models import Voucher


class VoucherSerializer(serializers.ModelSerializer):
    class Meta:
        model = Voucher
        fields = "__all__"

    def validate(self, attrs):
        start_at = attrs.get("start_at", getattr(self.instance, "start_at", None))
        end_at = attrs.get("end_at", getattr(self.instance, "end_at", None))
        discount_type = attrs.get(
            "discount_type", getattr(self.instance, "discount_type", None)
        )
        discount_value = attrs.get(
            "discount_value", getattr(self.instance, "discount_value", None)
        )
        max_discount_amount = attrs.get(
            "max_discount_amount", getattr(self.instance, "max_discount_amount", None)
        )

        if start_at and end_at and end_at <= start_at:
            raise serializers.ValidationError({"end_at": "end_at phải lớn hơn start_at"})

        if discount_value is not None and discount_value <= 0:
            raise serializers.ValidationError({"discount_value": "discount_value phải > 0"})

        if discount_type == Voucher.DISCOUNT_PERCENT:
            if discount_value and discount_value > 100:
                raise serializers.ValidationError({"discount_value": "Phần trăm tối đa 100"})
            if max_discount_amount is None:
                raise serializers.ValidationError(
                    {"max_discount_amount": "Cần max_discount_amount khi giảm theo %"}
                )
        return attrs

    def create(self, validated_data):
        validated_data["code"] = validated_data["code"].upper()
        return super().create(validated_data)

    def update(self, instance, validated_data):
        if "code" in validated_data:
            validated_data["code"] = validated_data["code"].upper()
        return super().update(instance, validated_data)


class VoucherPublicSerializer(serializers.ModelSerializer):
    class Meta:
        model = Voucher
        fields = [
            "id",
            "code",
            "title",
            "description",
            "discount_type",
            "discount_value",
            "max_discount_amount",
            "min_order_amount",
            "start_at",
            "end_at",
        ]
