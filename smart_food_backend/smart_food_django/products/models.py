from django.db import models
from stores.models import Store
from categories.models import Category


class Product(models.Model):
    store = models.ForeignKey(Store, on_delete=models.CASCADE, related_name="products")
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True, related_name="products")

    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)

    price = models.DecimalField(max_digits=10, decimal_places=2)
    discount_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)

    image = models.ImageField(upload_to="product_images/", null=True, blank=True)

    is_available = models.BooleanField(default=True)
    position = models.IntegerField(default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} - {self.store.store_name}"

    class Meta:
        db_table = "products"
        ordering = ["position", "-created_at"]


class OptionGroup(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name="option_groups")

    name = models.CharField(max_length=255)
    is_required = models.BooleanField(default=False)
    max_select = models.IntegerField(default=1)  # 1 = chọn 1, >1 = nhiều, 0 = không giới hạn
    position = models.IntegerField(default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} ({self.product.name})"

    class Meta:
        db_table = "option_groups"
        ordering = ["position", "-created_at"]


class Option(models.Model):
    option_group = models.ForeignKey(OptionGroup, on_delete=models.CASCADE, related_name="options")

    name = models.CharField(max_length=255)
    price = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    position = models.IntegerField(default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} ({self.option_group.name})"

    class Meta:
        db_table = "options"
        ordering = ["position", "-created_at"]


# ==============================
#   SHARED TEMPLATES
# ==============================
class OptionGroupTemplate(models.Model):
    store = models.ForeignKey(
        Store,
        on_delete=models.CASCADE,
        related_name="option_group_templates",
        null=True,
        blank=True,
    )
    name = models.CharField(max_length=255)
    is_required = models.BooleanField(default=False)
    max_select = models.IntegerField(default=1)
    position = models.IntegerField(default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

    class Meta:
        db_table = "option_group_templates"
        ordering = ["position", "-created_at"]


class OptionTemplate(models.Model):
    option_group_template = models.ForeignKey(
        OptionGroupTemplate,
        on_delete=models.CASCADE,
        related_name="options"
    )

    name = models.CharField(max_length=255)
    price = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    position = models.IntegerField(default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} ({self.option_group_template.name})"

    class Meta:
        db_table = "option_templates"
        ordering = ["position", "-created_at"]


class ProductOptionGroup(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name="template_groups")
    option_group_template = models.ForeignKey(
        OptionGroupTemplate,
        on_delete=models.CASCADE,
        related_name="product_links"
    )

    # overrides (optional)
    is_required = models.BooleanField(null=True, blank=True)
    max_select = models.IntegerField(null=True, blank=True)
    position = models.IntegerField(default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.option_group_template.name} -> {self.product.name}"

    class Meta:
        db_table = "product_option_groups"
        ordering = ["position", "-created_at"]
        unique_together = ("product", "option_group_template")
