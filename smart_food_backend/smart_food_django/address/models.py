from django.db import models
from django.conf import settings   

class Address(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,   
        on_delete=models.CASCADE,
        related_name="addresses"
    )

    label = models.CharField(max_length=50)
    is_default = models.BooleanField(default=False)

    address_line = models.TextField()
    receiver_name = models.CharField(max_length=100)
    receiver_phone = models.CharField(max_length=20)

    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "address" 

    def save(self, *args, **kwargs):
        if self.is_default:
            Address.objects.filter(
                user=self.user,
                is_default=True
            ).exclude(id=self.id).update(is_default=False)

        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.label} - {self.address_line}"
