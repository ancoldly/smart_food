from rest_framework import serializers
from .models import Notification


class NotificationSerializer(serializers.ModelSerializer):
    order_id = serializers.IntegerField(source="order.id", read_only=True)

    class Meta:
        model = Notification
        fields = ["id", "title", "message", "is_read", "order_id", "created_at"]
