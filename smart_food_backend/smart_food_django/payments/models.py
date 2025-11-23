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
