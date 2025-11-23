from django.contrib import admin
from .models import Payment

@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "bank_name", "account_number", "is_default")
    list_filter = ("bank_name", "is_default")
    search_fields = ("bank_name", "account_number", "account_holder")
