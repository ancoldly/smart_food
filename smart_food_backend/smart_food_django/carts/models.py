from django.conf import settings
from django.db import models


class Cart(models.Model):
    STATUS_CHOICES = (
        ("open", "Open"),
        ("checked_out", "Checked out"),
    )

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="carts",
    )
    store = models.ForeignKey(
        "stores.Store",
        on_delete=models.CASCADE,
        related_name="carts",
    )
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="open")

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "carts"
        indexes = [
            models.Index(fields=["user", "store"]),
        ]

    def __str__(self):
        return f"Cart #{self.id} - {self.user} - {self.store}"


class CartItem(models.Model):
    cart = models.ForeignKey(
        Cart,
        on_delete=models.CASCADE,
        related_name="items",
    )
    product = models.ForeignKey(
        "products.Product",
        on_delete=models.CASCADE,
        related_name="cart_items",
    )
    quantity = models.PositiveIntegerField(default=1)
    unit_price = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    note = models.CharField(max_length=255, blank=True, null=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "cart_items"
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.product} x {self.quantity}"

    @property
    def options_total(self):
        return sum(o.price for o in self.options.all())

    @property
    def line_total(self):
        return (self.unit_price + self.options_total) * self.quantity


class CartItemOption(models.Model):
    cart_item = models.ForeignKey(
        CartItem,
        on_delete=models.CASCADE,
        related_name="options",
    )
    option = models.ForeignKey(
        "products.Option",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="cart_item_options",
    )
    option_template = models.ForeignKey(
        "products.OptionTemplate",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="cart_item_options",
    )
    name = models.CharField(max_length=255)
    price = models.DecimalField(max_digits=12, decimal_places=2, default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "cart_item_options"

    def __str__(self):
        return self.name
