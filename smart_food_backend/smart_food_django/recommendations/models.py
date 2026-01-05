from django.conf import settings
from django.db import models


class UserInteraction(models.Model):
    EVENT_CHOICES = [
        ("store_view", "Store view"),
        ("product_view", "Product view"),
        ("add_to_cart", "Add to cart"),
        ("purchase", "Purchase"),
        ("store_favorite", "Favorite store"),
    ]

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="interactions"
    )
    product = models.ForeignKey(
        "products.Product",
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name="interactions",
    )
    store = models.ForeignKey(
        "stores.Store",
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name="interactions",
    )
    event = models.CharField(max_length=32, choices=EVENT_CHOICES)
    value = models.FloatField(default=0)
    weight = models.FloatField(default=0)
    meta = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "recommend_user_interactions"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["user", "product", "event"]),
            models.Index(fields=["product", "created_at"]),
            models.Index(fields=["user", "created_at"]),
        ]


class ProductRecommendation(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="recommendations"
    )
    product = models.ForeignKey(
        "products.Product",
        on_delete=models.CASCADE,
        related_name="user_recommendations",
    )
    score = models.FloatField(default=0)
    reason = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "recommend_product_recommendations"
        ordering = ["-score", "-updated_at"]
        unique_together = ("user", "product")


class ProductSimilarity(models.Model):
    product = models.ForeignKey(
        "products.Product", on_delete=models.CASCADE, related_name="similarities"
    )
    similar_product = models.ForeignKey(
        "products.Product", on_delete=models.CASCADE, related_name="similar_to"
    )
    score = models.FloatField(default=0)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "recommend_product_similarities"
        ordering = ["-score", "product_id"]
        unique_together = ("product", "similar_product")
        indexes = [
            models.Index(fields=["product", "-score"]),
        ]


class ProductPopularity(models.Model):
    product = models.OneToOneField(
        "products.Product", on_delete=models.CASCADE, related_name="popularity"
    )
    score = models.FloatField(default=0)
    window_start = models.DateTimeField(null=True, blank=True)
    window_end = models.DateTimeField(null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "recommend_product_popularity"
