from rest_framework import serializers

from products.serializers import ProductSerializer
from .models import UserInteraction, ProductRecommendation, ProductSimilarity


class InteractionCreateSerializer(serializers.Serializer):
    product_id = serializers.IntegerField(required=False)
    store_id = serializers.IntegerField(required=False)
    event = serializers.ChoiceField(choices=UserInteraction.EVENT_CHOICES)
    value = serializers.FloatField(required=False, default=0)
    weight = serializers.FloatField(required=False, allow_null=True)
    quantity = serializers.IntegerField(required=False, default=1)
    meta = serializers.DictField(required=False)


class RecommendationSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)

    class Meta:
        model = ProductRecommendation
        fields = ("product", "score", "reason")


class SimilarProductSerializer(serializers.ModelSerializer):
    similar_product = ProductSerializer(read_only=True)

    class Meta:
        model = ProductSimilarity
        fields = ("similar_product", "score")
