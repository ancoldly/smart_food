from django.contrib import admin
from .models import (
    Product,
    OptionGroup,
    Option,
    OptionGroupTemplate,
    OptionTemplate,
    ProductOptionGroup,
)


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "store", "category", "price", "is_available", "position", "created_at")
    list_filter = ("store", "category", "is_available")
    search_fields = ("name", "description")


@admin.register(OptionGroup)
class OptionGroupAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "product", "is_required", "max_select", "position")
    list_filter = ("product", "is_required")
    search_fields = ("name",)


@admin.register(Option)
class OptionAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "option_group", "price", "position")
    list_filter = ("option_group",)
    search_fields = ("name",)


@admin.register(OptionGroupTemplate)
class OptionGroupTemplateAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "is_required", "max_select", "position")
    search_fields = ("name",)


@admin.register(OptionTemplate)
class OptionTemplateAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "option_group_template", "price", "position")
    list_filter = ("option_group_template",)
    search_fields = ("name",)


@admin.register(ProductOptionGroup)
class ProductOptionGroupAdmin(admin.ModelAdmin):
    list_display = ("id", "product", "option_group_template", "is_required", "max_select", "position")
    list_filter = ("product", "option_group_template")
