from rest_framework import serializers
from .models import Employee


class EmployeeSerializer(serializers.ModelSerializer):
    avatar_image = serializers.ImageField(required=False)
    avatar_url = serializers.SerializerMethodField()

    class Meta:
        model = Employee
        fields = "__all__"
        read_only_fields = ("id", "created_at", "updated_at")

    def get_avatar_url(self, obj):
        request = self.context.get("request")
        if obj.avatar_image:
            return request.build_absolute_uri(obj.avatar_image.url)
        return None

