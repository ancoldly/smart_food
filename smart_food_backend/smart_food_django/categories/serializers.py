from rest_framework import serializers
from .models import Category
from django.utils.text import slugify


class CategorySerializer(serializers.ModelSerializer):
    image = serializers.ImageField(required=False)
    image_url = serializers.SerializerMethodField()
    class Meta:
        model = Category
        fields = "__all__"
        read_only_fields = ("id", "created_at", "updated_at", "store")

    def get_image_url(self, obj):
        request = self.context.get("request")
        if obj.image and request:
            return request.build_absolute_uri(obj.image.url)
        if obj.image:
            return obj.image.url
        return None

    def _ensure_slug(self, validated_data):
        name = validated_data.get("name") or ""
        slug_val = validated_data.get("slug")
        if not slug_val:
            slug_val = slugify(name)
        if not slug_val:
            raise serializers.ValidationError({"slug": "Slug is required."})
        validated_data["slug"] = slug_val
        return validated_data

    def create(self, validated_data):
        validated_data = self._ensure_slug(validated_data)
        return super().create(validated_data)

    def update(self, instance, validated_data):
        validated_data = self._ensure_slug(validated_data)
        return super().update(instance, validated_data)
