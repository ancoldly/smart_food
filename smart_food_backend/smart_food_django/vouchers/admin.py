from django.contrib import admin
from .models import Voucher


@admin.register(Voucher)
class VoucherAdmin(admin.ModelAdmin):
    list_display = (
        "code",
        "title",
        "discount_type",
        "discount_value",
        "start_at",
        "end_at",
        "is_active",
        "used_count",
    )
    search_fields = ("code", "title")
    list_filter = ("discount_type", "is_active")
