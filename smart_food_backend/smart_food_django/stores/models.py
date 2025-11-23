from django.db import models
from django.conf import settings

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

    background_image = models.ImageField(upload_to="store_backgrounds/", null=True, blank=True)

    status = models.IntegerField(choices=STATUS_CHOICES, default=1)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.store_name

    class Meta:
        db_table = 'stores'