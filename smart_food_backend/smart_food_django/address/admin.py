from django.contrib import admin
from .models import Address

@admin.register(Address)
class AddressAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "label", "is_default", "receiver_name")
    list_filter = ("is_default", "user")
