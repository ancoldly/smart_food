from django.contrib import admin
from .models import Category


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ("name", "store", "is_active", "created_at")
    list_filter = ("is_active", "store")
    search_fields = ("name", "store__store_name")
