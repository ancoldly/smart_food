from rest_framework import serializers
from .models import Shipper


class ShipperSerializer(serializers.ModelSerializer):
    class Meta:
        model = Shipper
        fields = "__all__"
        read_only_fields = ("id", "status", "created_at", "updated_at", "user")


class ShipperRegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = Shipper
        fields = [
            "full_name",
            "phone",
            "city",
            "address",
            "vehicle_type",
            "license_plate",
            "id_number",
            "latitude",
            "longitude",
        ]

    def create(self, validated_data):
        user = self.context["request"].user
        if Shipper.objects.filter(user=user).exists():
            raise serializers.ValidationError({"detail": "Đã đăng ký tài xế"})
        return Shipper.objects.create(user=user, **validated_data)
