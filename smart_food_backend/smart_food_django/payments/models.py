from django.db import models
from django.conf import settings   

class Payment(models.Model):
    user = models.ForeignKey(
    settings.AUTH_USER_MODEL,
    on_delete=models.CASCADE,
    related_name="payments"
)

    bank_name = models.CharField(max_length=100)
    bank_logo = models.ImageField(upload_to="banks/", blank=True, null=True)

    account_number = models.CharField(max_length=50)
    account_holder = models.CharField(max_length=100)
    id_number = models.CharField(max_length=20)

    is_default = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.bank_name} - {self.account_number}"
    class Meta:
        db_table = 'payments'


class Wallet(models.Model):
    ROLE_CHOICES = (
        ("merchant", "Merchant"),
        ("shipper", "Shipper"),
    )
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="wallets")
    role = models.CharField(max_length=20, choices=ROLE_CHOICES)
    balance = models.DecimalField(max_digits=14, decimal_places=2, default=0)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "wallets"
        unique_together = ("user", "role")

    def __str__(self):
        return f"{self.user} - {self.role} - {self.balance}"


class WalletTransaction(models.Model):
    wallet = models.ForeignKey(Wallet, on_delete=models.CASCADE, related_name="transactions")
    amount = models.DecimalField(max_digits=14, decimal_places=2)
    type = models.CharField(max_length=20, choices=(("topup", "Topup"), ("withdraw", "Withdraw")))
    note = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "wallet_transactions"
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.type} {self.amount}"
