from django.conf import settings
from django.db import models


class Order(models.Model):
    STATUS_CHOICES = (
        ("pending", "Pending"),
        ("preparing", "Preparing"),
        ("delivering", "Delivering"),
        ("completed", "Completed"),
        ("cancelled", "Cancelled"),
    )
    PAYMENT_METHOD_CHOICES = (
        ("cash", "Cash"),
        ("card", "Card"),
    )
    PAYMENT_STATUS_CHOICES = (
        ("unpaid", "Unpaid"),
        ("paid", "Paid"),
    )

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="orders",
    )
    store = models.ForeignKey(
        "stores.Store",
        on_delete=models.CASCADE,
        related_name="orders",
    )
    address_line = models.CharField(max_length=255)
    receiver_name = models.CharField(max_length=100)
    receiver_phone = models.CharField(max_length=30)
    address_latitude = models.FloatField(null=True, blank=True)
    address_longitude = models.FloatField(null=True, blank=True)

    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default="pending")
    payment_method = models.CharField(
        max_length=20, choices=PAYMENT_METHOD_CHOICES, default="cash"
    )
    payment_status = models.CharField(
        max_length=20, choices=PAYMENT_STATUS_CHOICES, default="unpaid"
    )

    subtotal = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    shipping_fee = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    discount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    total = models.DecimalField(max_digits=12, decimal_places=2, default=0)

    app_voucher = models.ForeignKey(
        "vouchers.Voucher",
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="orders",
    )
    store_voucher = models.ForeignKey(
        "stores.StoreVoucher",
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="orders",
    )
    shipper = models.ForeignKey(
        "shippers.Shipper",
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="orders",
    )

    merchant_earning = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    shipper_earning = models.DecimalField(max_digits=12, decimal_places=2, default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "orders"
        ordering = ["-created_at"]

    def __str__(self):
        return f"Order #{self.id}"


class OrderItem(models.Model):
    order = models.ForeignKey(
        Order, on_delete=models.CASCADE, related_name="items"
    )
    product = models.ForeignKey(
        "products.Product",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="order_items",
    )
    product_name = models.CharField(max_length=255)
    quantity = models.PositiveIntegerField(default=1)
    unit_price = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    line_total = models.DecimalField(max_digits=12, decimal_places=2, default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "order_items"

    def __str__(self):
        return f"{self.product_name} x{self.quantity}"


class OrderItemOption(models.Model):
    order_item = models.ForeignKey(
        OrderItem, on_delete=models.CASCADE, related_name="options"
    )
    name = models.CharField(max_length=255)
    price = models.DecimalField(max_digits=12, decimal_places=2, default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "order_item_options"

    def __str__(self):
        return self.name


class Review(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="reviews")
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name="reviews")
    store = models.ForeignKey("stores.Store", on_delete=models.CASCADE, related_name="reviews")
    product = models.ForeignKey(
        "products.Product",
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="reviews",
    )
    rating = models.PositiveSmallIntegerField()
    comment = models.TextField(null=True, blank=True)
    reply_comment = models.TextField(null=True, blank=True)
    reply_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "reviews"
        ordering = ["-created_at"]
        constraints = [
            models.UniqueConstraint(
                fields=["order", "store", "product"], name="unique_order_store_product_review"
            )
        ]

    def __str__(self):
        return f"Review {self.id}"
