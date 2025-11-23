from django.contrib import admin
from .models import Store

@admin.register(Store)
class StoreAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "store_name",
        "category",
        "city",
        "manager_name",
        "manager_phone",
        "status",
        "created_at",
    )
    list_filter = ("category", "status", "city")
    search_fields = (
        "store_name",
        "manager_name",
        "manager_phone",
        "manager_email",
        "city",
    )
    readonly_fields = ("created_at", "updated_at")
