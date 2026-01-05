from django.conf import settings
from django.db import models


class Shipper(models.Model):
    STATUS_CHOICES = (
        (1, "Pending"),
        (2, "Approved"),
        (3, "Rejected"),
        (4, "Banned"),
    )

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="shipper_profile",
        unique=True,
    )

    full_name = models.CharField(max_length=120)
    phone = models.CharField(max_length=20)
    city = models.CharField(max_length=100, blank=True)
    address = models.CharField(max_length=255, blank=True)

    vehicle_type = models.CharField(max_length=50, blank=True)
    license_plate = models.CharField(max_length=50, blank=True)
    id_number = models.CharField(max_length=30, blank=True)

    status = models.IntegerField(choices=STATUS_CHOICES, default=1)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "shippers"
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.full_name} - {self.user.email}"
