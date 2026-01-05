from rest_framework import serializers

from .models import (
    Product,
    OptionGroup,
    Option,
    OptionGroupTemplate,
    OptionTemplate,
    ProductOptionGroup,
)


class ProductSerializer(serializers.ModelSerializer):
    image = serializers.ImageField(required=False)
    image_url = serializers.SerializerMethodField()
    sold_count = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = "__all__"
        read_only_fields = ("id", "created_at", "updated_at", "store")

    def get_image_url(self, obj):
        request = self.context.get("request")
        if obj.image and request:
            return request.build_absolute_uri(obj.image.url)
        if obj.image:
            return obj.image.url
        return None

    def get_sold_count(self, obj):
        try:
            return obj.order_items.filter(order__status="completed").count()
        except Exception:
            return 0


class OptionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Option
        fields = "__all__"
        read_only_fields = ("id", "created_at", "updated_at")


class OptionGroupSerializer(serializers.ModelSerializer):
    options = OptionSerializer(many=True, read_only=True)

    class Meta:
        model = OptionGroup
        fields = "__all__"
        read_only_fields = ("id", "created_at", "updated_at")


# Templates
class OptionTemplateSerializer(serializers.ModelSerializer):
    class Meta:
        model = OptionTemplate
        fields = "__all__"
        read_only_fields = ("id", "created_at", "updated_at")


class OptionGroupTemplateSerializer(serializers.ModelSerializer):
    options = OptionTemplateSerializer(many=True, read_only=True)

    class Meta:
        model = OptionGroupTemplate
        fields = "__all__"
        read_only_fields = ("id", "created_at", "updated_at", "store")


class ProductOptionGroupSerializer(serializers.ModelSerializer):
    option_group_template = OptionGroupTemplateSerializer(read_only=True)
    option_group_template_id = serializers.PrimaryKeyRelatedField(
        queryset=OptionGroupTemplate.objects.none(),  # set in __init__
        source="option_group_template",
        write_only=True,
    )

    class Meta:
        model = ProductOptionGroup
        fields = [
            "id",
            "product",
            "option_group_template",
            "option_group_template_id",
            "is_required",
            "max_select",
            "position",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ("id", "created_at", "updated_at")

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        request = self.context.get("request")
        if request:
            if request.user.is_staff:
                qs = OptionGroupTemplate.objects.all()
            else:
                from stores.models import Store
                store = Store.objects.filter(user=request.user).first()
                qs = OptionGroupTemplate.objects.filter(store=store)
            self.fields["option_group_template_id"].queryset = qs
