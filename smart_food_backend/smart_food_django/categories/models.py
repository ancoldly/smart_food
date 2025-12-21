from django.db import models
from stores.models import Store


class Category(models.Model):
    store = models.ForeignKey(
        Store,
        on_delete=models.CASCADE,
        related_name="categories"
    )
    name = models.CharField(max_length=255)
    slug = models.SlugField(max_length=255, blank=True, null=True)
    description = models.TextField(blank=True, null=True)
    image = models.ImageField(upload_to="category_images/", null=True, blank=True)
    is_active = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} - {self.store.store_name}"

    class Meta:
        db_table = "categories"
        ordering = ["-created_at"]
