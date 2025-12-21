from django.db import models
from django.conf import settings
from django.contrib.auth import get_user_model

class Store(models.Model):
    CATEGORY_CHOICES = (
        ("food", "Food"),
        ("mart", "Mart"),
    )

    STATUS_CHOICES = (
        (1, "Pending"),
        (2, "Approved"),
        (3, "Rejected"),
        (4, "Banned"),
    )

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="stores")

    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    store_name = models.CharField(max_length=255)
    city = models.CharField(max_length=100)
    address = models.TextField()

    manager_name = models.CharField(max_length=255)
    manager_phone = models.CharField(max_length=20)
    manager_email = models.CharField(max_length=255)

    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)

    avatar_image = models.ImageField(upload_to="store_avatar", null=True, blank=True)
    background_image = models.ImageField(upload_to="store_background", null=True, blank=True)

    status = models.IntegerField(choices=STATUS_CHOICES, default=1)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.store_name

    class Meta:
        db_table = 'stores'


class StoreTag(models.Model):
    store = models.ForeignKey(Store, on_delete=models.CASCADE, related_name="tags")
    name = models.CharField(max_length=100)
    slug = models.SlugField(max_length=120, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.store.store_name} - {self.name}"

    class Meta:
        db_table = "store_tags"
        unique_together = ("store", "slug")


class StoreOperatingHour(models.Model):
    store = models.ForeignKey(Store, on_delete=models.CASCADE, related_name="operating_hours")
    day_of_week = models.PositiveSmallIntegerField()  # 0 = Monday, 6 = Sunday
    open_time = models.TimeField(null=True, blank=True)
    close_time = models.TimeField(null=True, blank=True)
    is_closed = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "store_operating_hours"
        unique_together = ("store", "day_of_week")
        ordering = ["day_of_week"]

    def __str__(self):
        return f"{self.store.store_name} - {self.day_of_week}"


class StoreVoucher(models.Model):
    DISCOUNT_TYPE_CHOICES = (
        ("percent", "Percent"),
        ("fixed", "Fixed"),
    )

    store = models.ForeignKey(Store, on_delete=models.CASCADE, related_name="store_vouchers")
    code = models.CharField(max_length=50)
    description = models.TextField(blank=True)
    discount_type = models.CharField(max_length=10, choices=DISCOUNT_TYPE_CHOICES, default="percent")
    discount_value = models.DecimalField(max_digits=10, decimal_places=2)
    min_order_value = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    max_discount_value = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    start_date = models.DateTimeField(null=True, blank=True)
    end_date = models.DateTimeField(null=True, blank=True)
    usage_limit = models.PositiveIntegerField(null=True, blank=True)
    used_count = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "store_vouchers"
        ordering = ["-created_at"]
        unique_together = ("store", "code")

    def __str__(self):
        return f"{self.code} - {self.store.store_name}"


class StoreCampaign(models.Model):
    store = models.ForeignKey(Store, on_delete=models.CASCADE, related_name="campaigns")
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    banner_url = models.URLField(blank=True)
    start_date = models.DateTimeField(null=True, blank=True)
    end_date = models.DateTimeField(null=True, blank=True)
    budget = models.DecimalField(max_digits=14, decimal_places=2, default=0)
    impressions = models.PositiveIntegerField(default=0)
    clicks = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "store_campaigns"
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.title} - {self.store.store_name}"


class FavoriteStore(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="favorite_stores")
    store = models.ForeignKey(Store, on_delete=models.CASCADE, related_name="favorited_by")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "favorite_stores"
        unique_together = ("user", "store")
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.user} -> {self.store}"
