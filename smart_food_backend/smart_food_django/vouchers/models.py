from django.db import models
from django.utils import timezone


class Voucher(models.Model):
    DISCOUNT_PERCENT = "percent"
    DISCOUNT_FIXED = "fixed"
    DISCOUNT_CHOICES = [
        (DISCOUNT_PERCENT, "Percent"),
        (DISCOUNT_FIXED, "Fixed"),
    ]

    code = models.CharField(max_length=50, unique=True)
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)

    discount_type = models.CharField(max_length=20, choices=DISCOUNT_CHOICES)
    discount_value = models.DecimalField(max_digits=10, decimal_places=2)
    max_discount_amount = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True
    )  # áp dụng khi là percent
    min_order_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)

    start_at = models.DateTimeField()
    end_at = models.DateTimeField()

    usage_limit_total = models.IntegerField(null=True, blank=True)  # null = không giới hạn
    usage_limit_per_user = models.IntegerField(default=1)
    used_count = models.IntegerField(default=0)

    is_active = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "vouchers"
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.code} - {self.title}"

    def is_valid_now(self):
        now = timezone.now()
        if not self.is_active:
            return False
        if self.start_at and now < self.start_at:
            return False
        if self.end_at and now > self.end_at:
            return False
        if self.usage_limit_total is not None and self.used_count >= self.usage_limit_total:
            return False
        return True
