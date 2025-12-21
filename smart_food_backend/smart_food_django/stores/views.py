from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.views import APIView
from rest_framework.decorators import api_view, permission_classes

from django.shortcuts import get_object_or_404
from django.db.models import Q
from django.utils.text import slugify
import re

from users.permissions import IsAdminRole
from rest_framework.permissions import AllowAny

from .models import Store, StoreTag, FavoriteStore, StoreOperatingHour, StoreVoucher, StoreCampaign
from .serializers import (
    StoreSerializer,
    StoreTagSerializer,
    FavoriteStoreSerializer,
    StoreOperatingHourSerializer,
    StoreVoucherSerializer,
    StoreCampaignSerializer,
)


def _word_regex(token: str) -> str:
    """Tạo regex biên từ, ví dụ token='bun' => r'(^|\\s)bun(\\s|$)'"""
    safe = re.escape(token)
    return rf"(^|\s){safe}(\s|$)"


# USER: GET MY STORE
class UserStoreDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        store = Store.objects.filter(user=request.user).first()
        if not store:
            return Response(None, status=200)
        serializer = StoreSerializer(store, context={"request": request})
        return Response(serializer.data, status=200)


# USER: CREATE STORE
class StoreCreateView(generics.CreateAPIView):
    serializer_class = StoreSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user, status=1)

    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        response.status_code = status.HTTP_201_CREATED
        return response


# USER: UPDATE / DELETE STORE
class StoreDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = StoreSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Store.objects.filter(user=self.request.user)

    def update(self, request, *args, **kwargs):
        response = super().update(request, *args, **kwargs)
        response.status_code = status.HTTP_200_OK
        return response

    def destroy(self, request, *args, **kwargs):
        super().destroy(request, *args, **kwargs)
        return Response(status=status.HTTP_204_NO_CONTENT)


# USER: TOGGLE STORE STATUS
class ToggleStoreStatusView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        store = get_object_or_404(Store, pk=pk, user=request.user)
        if store.status == 4:
            store.status = 2
            msg = "Đã mở cửa hàng"
        else:
            store.status = 4
            msg = "Đã đóng cửa hàng"
        store.save()
        return Response({"success": True, "message": msg}, status=200)


class StoreOperatingHourListView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        store = Store.objects.filter(user=request.user).first()
        if not store:
            return Response({"detail": "Store not found"}, status=400)

        self._ensure_hours(store)
        hours = StoreOperatingHour.objects.filter(store=store).order_by("day_of_week")
        serializer = StoreOperatingHourSerializer(hours, many=True)
        return Response(serializer.data, status=200)

    def _ensure_hours(self, store: Store):
        existing = set(
            StoreOperatingHour.objects.filter(store=store).values_list("day_of_week", flat=True)
        )
        for day in range(7):
            if day not in existing:
                StoreOperatingHour.objects.create(
                    store=store, day_of_week=day, is_closed=True
                )


class StoreOperatingHourDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        store = Store.objects.filter(user=request.user).first()
        if not store:
            return Response({"detail": "Store not found"}, status=400)
        hour = StoreOperatingHour.objects.filter(pk=pk, store=store).first()
        if not hour:
            return Response({"detail": "Operating hour not found"}, status=404)

        serializer = StoreOperatingHourSerializer(hour, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save(store=store)
        return Response(serializer.data, status=200)


class StoreVoucherListCreateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        store = Store.objects.filter(user=request.user).first()
        if not store:
            return Response({"detail": "Store not found"}, status=400)
        vouchers = StoreVoucher.objects.filter(store=store).order_by("-created_at")
        serializer = StoreVoucherSerializer(vouchers, many=True)
        return Response(serializer.data, status=200)

    def post(self, request):
        store = Store.objects.filter(user=request.user).first()
        if not store:
            return Response({"detail": "Store not found"}, status=400)
        data = request.data.copy()
        data["store"] = store.id
        serializer = StoreVoucherSerializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save(store=store)
        return Response(serializer.data, status=201)


class StoreVoucherDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self, request, pk):
        store = Store.objects.filter(user=request.user).first()
        if not store:
            return None, Response({"detail": "Store not found"}, status=400)
        voucher = StoreVoucher.objects.filter(pk=pk, store=store).first()
        if not voucher:
            return None, Response({"detail": "Voucher not found"}, status=404)
        return voucher, None

    def get(self, request, pk):
        voucher, err = self.get_object(request, pk)
        if err:
            return err
        serializer = StoreVoucherSerializer(voucher)
        return Response(serializer.data, status=200)

    def patch(self, request, pk):
        voucher, err = self.get_object(request, pk)
        if err:
            return err
        serializer = StoreVoucherSerializer(voucher, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=200)

    def delete(self, request, pk):
        voucher, err = self.get_object(request, pk)
        if err:
            return err
        voucher.delete()
        return Response(status=204)


class StoreCampaignListCreateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        store = Store.objects.filter(user=request.user).first()
        if not store:
            return Response({"detail": "Store not found"}, status=400)
        campaigns = StoreCampaign.objects.filter(store=store).order_by("-created_at")
        serializer = StoreCampaignSerializer(campaigns, many=True)
        return Response(serializer.data, status=200)

    def post(self, request):
        store = Store.objects.filter(user=request.user).first()
        if not store:
            return Response({"detail": "Store not found"}, status=400)
        data = request.data.copy()
        data["store"] = store.id
        serializer = StoreCampaignSerializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save(store=store)
        return Response(serializer.data, status=201)


class StoreCampaignDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self, request, pk):
        store = Store.objects.filter(user=request.user).first()
        if not store:
            return None, Response({"detail": "Store not found"}, status=400)
        campaign = StoreCampaign.objects.filter(pk=pk, store=store).first()
        if not campaign:
            return None, Response({"detail": "Campaign not found"}, status=404)
        return campaign, None

    def get(self, request, pk):
        campaign, err = self.get_object(request, pk)
        if err:
            return err
        serializer = StoreCampaignSerializer(campaign)
        return Response(serializer.data, status=200)

    def patch(self, request, pk):
        campaign, err = self.get_object(request, pk)
        if err:
            return err
        serializer = StoreCampaignSerializer(campaign, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=200)

    def delete(self, request, pk):
        campaign, err = self.get_object(request, pk)
        if err:
            return err
        campaign.delete()
        return Response(status=204)


@api_view(["POST"])
@permission_classes([AllowAny])
def store_campaign_impression(request, pk):
    campaign = StoreCampaign.objects.filter(pk=pk).first()
    if not campaign:
        return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
    campaign.impressions = (campaign.impressions or 0) + 1
    campaign.save(update_fields=["impressions"])
    return Response({"impressions": campaign.impressions})


@api_view(["POST"])
@permission_classes([AllowAny])
def store_campaign_click(request, pk):
    campaign = StoreCampaign.objects.filter(pk=pk).first()
    if not campaign:
        return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
    campaign.clicks = (campaign.clicks or 0) + 1
    campaign.save(update_fields=["clicks"])
    return Response({"clicks": campaign.clicks})


# USER: FAVORITE / UNFAVORITE STORE
class FavoriteStoreListToggleView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        favs = FavoriteStore.objects.filter(user=request.user).select_related("store")
        serializer = FavoriteStoreSerializer(favs, many=True)
        store_ids = [item["store"] for item in serializer.data]
        return Response({"store_ids": store_ids}, status=200)

    def post(self, request):
        store_id = request.data.get("store_id")
        if not store_id:
            return Response({"detail": "store_id required"}, status=400)
        store = Store.objects.filter(id=store_id).first()
        if not store:
            return Response({"detail": "Store not found"}, status=404)

        fav = FavoriteStore.objects.filter(user=request.user, store=store).first()
        if fav:
            fav.delete()
            return Response({"is_favorite": False}, status=200)
        FavoriteStore.objects.create(user=request.user, store=store)
        return Response({"is_favorite": True}, status=201)


# ADMIN: LIST ALL STORES
class AdminStoreListView(APIView):
    permission_classes = [IsAdminRole]

    def get(self, request):
        stores = Store.objects.all().order_by("-created_at")
        serializer = StoreSerializer(stores, many=True, context={"request": request})
        return Response(serializer.data, status=200)


# STORE TAGS (merchant only)
class StoreTagListCreateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        store = Store.objects.filter(user=request.user).first()
        if not store:
            return Response({"detail": "Store not found"}, status=400)
        tags = StoreTag.objects.filter(store=store).order_by("-created_at")
        serializer = StoreTagSerializer(tags, many=True)
        return Response(serializer.data, status=200)

    def post(self, request):
        store = Store.objects.filter(user=request.user).first()
        if not store:
            return Response({"detail": "Store not found"}, status=400)
        data = request.data.copy()
        data["store"] = store.id
        serializer = StoreTagSerializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save(store=store)
        return Response(serializer.data, status=201)


class StoreTagDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self, request, pk):
        store = Store.objects.filter(user=request.user).first()
        if not store:
            return None, Response({"detail": "Store not found"}, status=400)
        tag = StoreTag.objects.filter(pk=pk, store=store).first()
        if not tag:
            return None, Response({"detail": "Tag not found"}, status=404)
        return tag, None

    def patch(self, request, pk):
        tag, err = self.get_object(request, pk)
        if err:
            return err
        data = request.data.copy()
        serializer = StoreTagSerializer(tag, data=data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=200)

    def delete(self, request, pk):
        tag, err = self.get_object(request, pk)
        if err:
            return err
        tag.delete()
        return Response(status=204)


# PUBLIC: LIST APPROVED STORES WITH KEYWORD/CATEGORY FILTER
class PublicStoreListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        stores = Store.objects.filter(status__in=[2, 4])

        category_kw = request.query_params.get("product_category")
        search_kw = request.query_params.get("keyword")

        q = Q()

        if category_kw:
            kw_full = category_kw.strip().lower()
            if kw_full:
                tokens = [kw_full] + [
                    t for t in kw_full.replace(",", " ").split() if len(t.strip()) >= 2
                ]
                for tok in tokens:
                    tok = tok.strip()
                    if not tok:
                        continue
                    slug_tok = slugify(tok)
                    for candidate in {tok, slug_tok}:
                        pattern = _word_regex(candidate)
                        q |= Q(store_name__iregex=pattern)
                        q |= Q(products__category__name__iregex=pattern)
                        q |= Q(products__category__slug__iregex=pattern)
                        q |= Q(products__name__iregex=pattern)
                        q |= Q(tags__slug__iregex=pattern) | Q(tags__name__iregex=pattern)

        # Tìm kiếm tự do: ưu tiên cụm đầy đủ + từ đầu tiên (regex biên từ để tránh match chuỗi con)
        if search_kw:
            kw_full = search_kw.lower().strip()
            if kw_full:
                kw_full_slug = slugify(kw_full)
                first_word = kw_full.split()[0]
                first_slug = slugify(first_word)

                full_pattern = _word_regex(kw_full)
                full_slug_pattern = _word_regex(kw_full_slug)
                q |= Q(store_name__iregex=full_pattern) | Q(store_name__iregex=full_slug_pattern)
                q |= Q(products__category__name__iregex=full_pattern) | Q(
                    products__category__name__iregex=full_slug_pattern
                )
                q |= Q(products__category__slug__iregex=full_pattern) | Q(
                    products__category__slug__iregex=full_slug_pattern
                )
                q |= Q(products__name__iregex=full_pattern) | Q(
                    products__name__iregex=full_slug_pattern
                )
                q |= Q(tags__name__iregex=full_pattern) | Q(tags__slug__iregex=full_pattern)

                if first_word:
                    fw_pattern = _word_regex(first_word)
                    fs_pattern = _word_regex(first_slug)
                    q |= Q(store_name__iregex=fw_pattern) | Q(store_name__iregex=fs_pattern)
                    q |= Q(products__category__name__iregex=fw_pattern) | Q(
                        products__category__name__iregex=fs_pattern
                    )
                    q |= Q(products__category__slug__iregex=fw_pattern) | Q(
                        products__category__slug__iregex=fs_pattern
                    )
                    q |= Q(products__name__iregex=fw_pattern) | Q(
                        products__name__iregex=fs_pattern
                    )
                    q |= Q(tags__name__iregex=fw_pattern) | Q(tags__slug__iregex=fw_pattern)

        if q:
            stores = stores.filter(q)

        stores = stores.distinct().order_by("-created_at")
        serializer = StoreSerializer(stores, many=True, context={"request": request})
        return Response(serializer.data, status=200)


# ADMIN: APPROVE STORE
class ApproveStoreView(APIView):
    permission_classes = [IsAdminRole]

    def post(self, request, pk):
        store = get_object_or_404(Store, pk=pk)
        store.status = 2
        store.save()
        user = store.user
        user.role = "merchant"
        user.save()
        return Response(
            {
                "success": True,
                "message": "Đã duyệt cửa hàng và chuyển role user thành merchant",
            },
            status=200,
        )


# ADMIN: REJECT STORE
class RejectStoreView(APIView):
    permission_classes = [IsAdminRole]

    def post(self, request, pk):
        store = get_object_or_404(Store, pk=pk)
        store.status = 3
        store.save()
        return Response({"success": True, "message": "Đã từ chối cửa hàng"}, status=200)
