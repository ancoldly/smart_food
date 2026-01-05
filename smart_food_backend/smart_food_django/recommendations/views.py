from datetime import timedelta

from django.db.models import Sum
from django.utils import timezone
from rest_framework import permissions
from rest_framework.response import Response
from rest_framework.views import APIView

from products.models import Product
from products.serializers import ProductSerializer
from stores.models import Store
from .models import (
    UserInteraction,
    ProductRecommendation,
    ProductSimilarity,
    ProductPopularity,
)
from .serializers import (
    InteractionCreateSerializer,
    RecommendationSerializer,
    SimilarProductSerializer,
)
from .services import log_interaction


def _popular_products(limit: int):
    items = list(
        ProductPopularity.objects.select_related("product")
        .order_by("-score", "-updated_at")[:limit]
    )
    if items:
        return [{"product": it.product, "score": it.score, "reason": "popularity"} for it in items], "popularity"

    window = timezone.now() - timedelta(days=30)
    qs = (
        UserInteraction.objects.filter(
            product__isnull=False,
            weight__gt=0,
            created_at__gte=window,
        )
        .values("product")
        .annotate(score=Sum("weight"))
        .order_by("-score")
    )[:limit]
    products = Product.objects.in_bulk([row["product"] for row in qs])
    fallback = []
    for row in qs:
        product = products.get(row["product"])
        if product:
            fallback.append(
                {"product": product, "score": row["score"], "reason": "recent_popularity"}
            )
    return fallback, "recent_popularity"


class InteractionIngestView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = InteractionCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                {"detail": "skipped", "errors": serializer.errors, "created": False},
                status=200,
            )
        data = serializer.validated_data

        product = None
        store = None
        if data.get("product_id"):
            product = Product.objects.filter(id=data["product_id"]).first()
        if data.get("store_id"):
            store = Store.objects.filter(id=data["store_id"]).first()
        if not store and product:
            store = getattr(product, "store", None)
        if not product and not store:
            return Response(
                {"detail": "skipped: missing product/store", "created": False},
                status=200,
            )

        obj, err = log_interaction(
            user=request.user,
            product=product,
            store=store,
            event=data["event"],
            value=data.get("value") or 0,
            weight=data.get("weight"),
            quantity=data.get("quantity") or 1,
            meta=data.get("meta"),
        )
        if obj:
            return Response(
                {
                    "detail": "logged",
                    "created": True,
                    "event": data["event"],
                    "product_id": product.id if product else None,
                    "store_id": store.id if store else None,
                },
                status=201,
            )
        return Response(
            {
                "detail": "skipped: failed to save",
                "created": False,
                "event": data["event"],
                "product_id": product.id if product else None,
                "store_id": store.id if store else None,
                "error": err,
            },
            status=200,
        )


class RecommendationFeedView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        try:
            limit = int(request.query_params.get("limit", 20))
        except Exception:
            limit = 20
        qs = (
            ProductRecommendation.objects.filter(user=request.user)
            .select_related("product", "product__store")
            .order_by("-score", "-updated_at")[:limit]
        )
        if qs:
            data = RecommendationSerializer(
                qs, many=True, context={"request": request}
            ).data
            return Response({"items": data, "source": "personalized"}, status=200)

        fallback, source = _popular_products(limit)
        data = [
            {
                "product": ProductSerializer(
                    item["product"], context={"request": request}
                ).data,
                "score": item["score"],
                "reason": item["reason"],
            }
            for item in fallback
        ]
        return Response({"items": data, "source": source}, status=200)


class SimilarProductsView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        product_id = request.query_params.get("product_id")
        if not product_id:
            return Response({"detail": "product_id là bắt buộc"}, status=400)
        try:
            limit = int(request.query_params.get("limit", 10))
        except Exception:
            limit = 10

        sims = (
            ProductSimilarity.objects.filter(product_id=product_id)
            .select_related("similar_product", "similar_product__store")
            .order_by("-score")[:limit]
        )
        if sims:
            data = SimilarProductSerializer(
                sims, many=True, context={"request": request}
            ).data
            return Response({"items": data, "source": "similarity"}, status=200)

        fallback, source = _popular_products(limit)
        data = [
            {
                "similar_product": ProductSerializer(
                    item["product"], context={"request": request}
                ).data,
                "score": item["score"],
                "reason": item["reason"],
            }
            for item in fallback
        ]
        return Response({"items": data, "source": source}, status=200)
