from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Shipper
from .serializers import ShipperSerializer, ShipperRegisterSerializer
from users.permissions import IsAdminRole


class ShipperRegisterView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = ShipperRegisterSerializer(
            data=request.data, context={"request": request}
        )
        if serializer.is_valid():
            shipper = serializer.save()
            return Response(ShipperSerializer(shipper).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ShipperMeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        shipper = Shipper.objects.filter(user=request.user).first()
        if not shipper:
            return Response({"detail": "Chua dang ky tai xe"}, status=404)
        data = ShipperSerializer(shipper).data
        return Response(data, status=200)

    def patch(self, request):
        shipper = Shipper.objects.filter(user=request.user).first()
        if not shipper:
            return Response({"detail": "Chua dang ky tai xe"}, status=404)

        allowed = [
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
        for field in allowed:
            if field in request.data:
                val = request.data.get(field)
                if field in ["latitude", "longitude"]:
                    try:
                        val = float(val)
                    except (TypeError, ValueError):
                        continue
                setattr(shipper, field, val)
        shipper.save()
        return Response(ShipperSerializer(shipper).data, status=200)


class ShipperStatusToggleView(APIView):
    """
    Shipper tự đổi trạng thái nhận đơn (online => status=4, offline => status=2)
    """

    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request):
        shipper = Shipper.objects.filter(user=request.user).first()
        if not shipper:
            return Response({"detail": "Chua dang ky tai xe"}, status=404)

        online = request.data.get("online", False)
        online_flag = str(online).lower() not in ["false", "0", "off", "none", ""]

        shipper.status = 4 if online_flag else 2
        shipper.save(update_fields=["status", "updated_at"])

        data = ShipperSerializer(shipper).data
        return Response(data, status=200)


class ShipperLocationUpdateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request):
        shipper = Shipper.objects.filter(user=request.user).first()
        if not shipper:
            return Response({"detail": "Chua dang ky tai xe"}, status=404)

        lat = request.data.get("latitude")
        lng = request.data.get("longitude")
        try:
            lat_val = float(lat)
            lng_val = float(lng)
        except (TypeError, ValueError):
            return Response({"detail": "Toa do khong hop le"}, status=400)

        shipper.latitude = lat_val
        shipper.longitude = lng_val
        shipper.save(update_fields=["latitude", "longitude", "updated_at"])
        return Response(ShipperSerializer(shipper).data, status=200)


class ShipperAdminListView(APIView):
    """
    Admin: list shipper, filter ?status=1|2|3|4
    """

    permission_classes = [IsAdminRole]

    def get(self, request):
        status_param = request.query_params.get("status")
        qs = Shipper.objects.select_related("user").all().order_by("-created_at")
        if status_param is not None:
            try:
                status_int = int(status_param)
                qs = qs.filter(status=status_int)
            except ValueError:
                pass
        serializer = ShipperSerializer(qs, many=True)
        return Response(serializer.data, status=200)


class ShipperApproveView(APIView):
    permission_classes = [IsAdminRole]

    def post(self, request, pk):
        try:
            shipper = Shipper.objects.get(pk=pk)
        except Shipper.DoesNotExist:
            return Response({"detail": "Not found"}, status=404)

        shipper.status = 2
        shipper.save(update_fields=["status", "updated_at"])

        if shipper.user.role != "shipper":
            shipper.user.role = "shipper"
            shipper.user.save(update_fields=["role"])

        return Response(ShipperSerializer(shipper).data, status=200)


class ShipperRejectView(APIView):
    permission_classes = [IsAdminRole]

    def post(self, request, pk):
        try:
            shipper = Shipper.objects.get(pk=pk)
        except Shipper.DoesNotExist:
            return Response({"detail": "Not found"}, status=404)

        shipper.status = 3
        shipper.save(update_fields=["status", "updated_at"])
        return Response(ShipperSerializer(shipper).data, status=200)


class ShipperBanView(APIView):
    permission_classes = [IsAdminRole]

    def post(self, request, pk):
        ban_flag = request.data.get("ban", True)
        try:
            ban_flag = bool(ban_flag) and str(ban_flag).lower() != "false"
        except Exception:
            ban_flag = True

        try:
            shipper = Shipper.objects.get(pk=pk)
        except Shipper.DoesNotExist:
            return Response({"detail": "Not found"}, status=404)

        shipper.status = 4 if ban_flag else 2
        shipper.save(update_fields=["status", "updated_at"])

        if shipper.status == 2 and shipper.user.role != "shipper":
            shipper.user.role = "shipper"
            shipper.user.save(update_fields=["role"])

        return Response(ShipperSerializer(shipper).data, status=200)


class ShipperAdminStatusView(APIView):
    permission_classes = [IsAdminRole]

    def patch(self, request, pk):
        try:
            shipper = Shipper.objects.get(pk=pk)
        except Shipper.DoesNotExist:
            return Response({"detail": "Not found"}, status=404)

        new_status = request.data.get("status")
        try:
            new_status = int(new_status)
        except (TypeError, ValueError):
            return Response(
                {"detail": "Invalid status"}, status=status.HTTP_400_BAD_REQUEST
            )

        valid_status = [choice[0] for choice in Shipper.STATUS_CHOICES]
        if new_status not in valid_status:
            return Response(
                {"detail": "Invalid status"}, status=status.HTTP_400_BAD_REQUEST
            )

        shipper.status = new_status
        shipper.save(update_fields=["status", "updated_at"])

        if new_status == 2 and shipper.user.role != "shipper":
            shipper.user.role = "shipper"
            shipper.user.save(update_fields=["role"])

        return Response(ShipperSerializer(shipper).data, status=200)
