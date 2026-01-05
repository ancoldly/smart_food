from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Notification
from .serializers import NotificationSerializer


class NotificationListView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = Notification.objects.filter(user=request.user).order_by("-created_at")
        if request.query_params.get("unread") == "1":
            qs = qs.filter(is_read=False)
        data = NotificationSerializer(qs, many=True).data
        return Response(data, status=200)


class NotificationMarkReadView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        notif = Notification.objects.filter(id=pk, user=request.user).first()
        if not notif:
            return Response({"detail": "Không tìm thấy thông báo"}, status=404)
        notif.is_read = True
        notif.save(update_fields=["is_read"])
        return Response(NotificationSerializer(notif).data, status=200)
