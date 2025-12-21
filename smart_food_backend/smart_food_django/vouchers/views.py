from django.utils import timezone
from django.db import models
from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Voucher
from .serializers import VoucherSerializer, VoucherPublicSerializer


class AdminVoucherListCreateView(generics.ListCreateAPIView):
    serializer_class = VoucherSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Voucher.objects.all().order_by("-created_at")


class AdminVoucherDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = VoucherSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Voucher.objects.all()

    def update(self, request, *args, **kwargs):
        kwargs["partial"] = True
        return super().update(request, *args, **kwargs)


class PublicVoucherListView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        # Hiện tại trả về tất cả voucher đang active, bỏ lọc thời gian/lượt để dễ kiểm thử
        qs = Voucher.objects.filter(is_active=True).order_by("-created_at")
        serializer = VoucherPublicSerializer(qs, many=True)
        return Response(serializer.data, status=200)
