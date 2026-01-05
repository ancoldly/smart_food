from rest_framework import generics, permissions, serializers
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny

from stores.models import Store
from categories.models import Category
from .models import (
    Product,
    OptionGroup,
    Option,
    OptionGroupTemplate,
    OptionTemplate,
    ProductOptionGroup,
)
from .serializers import (
    ProductSerializer,
    OptionGroupSerializer,
    OptionSerializer,
    OptionGroupTemplateSerializer,
    OptionTemplateSerializer,
    ProductOptionGroupSerializer,
)


class PublicOptionGroupByProductView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, product_id):
        qs = OptionGroup.objects.filter(
            product_id=product_id, product__is_available=True
        ).order_by("position", "-created_at")
        serializer = OptionGroupSerializer(qs, many=True)
        return Response(serializer.data, status=200)


class PublicProductOptionsView(APIView):
    """
    Trả về tất cả option groups cho product:
    - OptionGroup riêng của product.
    - OptionGroupTemplate được gán qua ProductOptionGroup (có override is_required, max_select).
    Output schema khớp OptionGroupSerializer để frontend dùng chung.
    """

    permission_classes = [AllowAny]

    def get(self, request, product_id):
        try:
            product = Product.objects.get(pk=product_id, is_available=True)
        except Product.DoesNotExist:
            return Response({"detail": "Not found"}, status=404)

        groups = []

        # Option groups riêng
        og_qs = OptionGroup.objects.filter(product=product).order_by(
            "position", "-created_at"
        )
        groups.extend(OptionGroupSerializer(og_qs, many=True).data)

        # Option template gán qua mapping
        pog_qs = (
            ProductOptionGroup.objects.filter(product=product)
            .select_related("option_group_template")
            .prefetch_related("option_group_template__options")
            .order_by("position", "-created_at")
        )

        for link in pog_qs:
            tpl = link.option_group_template
            synthetic_id = -tpl.id  # tránh đụng OptionGroup id thật

            data = {
                "id": synthetic_id,
                "product": product.id,
                "name": tpl.name,
                "is_required": link.is_required
                if link.is_required is not None
                else tpl.is_required,
                "max_select": link.max_select
                if link.max_select is not None
                else tpl.max_select,
                "position": link.position,
                "created_at": tpl.created_at,
                "updated_at": tpl.updated_at,
                "options": [],
            }

            for opt in tpl.options.all().order_by("position", "-created_at"):
                data["options"].append(
                    {
                        "id": opt.id,
                        "option_group": synthetic_id,
                        "name": opt.name,
                        "price": opt.price,
                        "position": opt.position,
                        "created_at": opt.created_at,
                        "updated_at": opt.updated_at,
                    }
                )

            groups.append(data)

        groups.sort(key=lambda g: g.get("position", 0))
        return Response(groups, status=200)


# =====================================
#              PRODUCTS
# =====================================
class ProductListCreateView(generics.ListCreateAPIView):
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get_queryset(self):
        store = Store.objects.filter(user=self.request.user).first()
        return Product.objects.filter(store=store).order_by("position", "-created_at")

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = ProductSerializer(queryset, many=True, context={"request": request})
        return Response(serializer.data, status=200)

    def perform_create(self, serializer):
        store = Store.objects.filter(user=self.request.user).first()
        if store is None:
            raise serializers.ValidationError({"store": "User does not have a store"})

        # Validate category belongs to store (if provided)
        category = serializer.validated_data.get("category")
        if category and category.store != store:
            raise serializers.ValidationError({"category": "Category does not belong to this store"})

        serializer.save(store=store)

    def create(self, request, *args, **kwargs):
        super().create(request, *args, **kwargs)
        store = Store.objects.filter(user=request.user).first()
        product = Product.objects.filter(store=store).order_by("-created_at").first()
        serializer = ProductSerializer(product, context={"request": request})
        return Response(serializer.data, status=201)


class ProductDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get_queryset(self):
        store = Store.objects.filter(user=self.request.user).first()
        return Product.objects.filter(store=store)

    def retrieve(self, request, *args, **kwargs):
        product = self.get_object()
        serializer = ProductSerializer(product, context={"request": request})
        return Response(serializer.data, status=200)

    def perform_update(self, serializer):
        store = Store.objects.filter(user=self.request.user).first()
        if store is None:
            raise serializers.ValidationError({"store": "User does not have a store"})

        category = serializer.validated_data.get("category")
        if category and category.store != store:
            raise serializers.ValidationError({"category": "Category does not belong to this store"})

        serializer.save(store=store)

    def update(self, request, *args, **kwargs):
        kwargs["partial"] = True
        return super().update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        super().destroy(request, *args, **kwargs)
        return Response(status=204)


class AdminProductListView(APIView):
    permission_classes = [permissions.IsAdminUser]

    def get(self, request):
        products = Product.objects.all().order_by("position", "-created_at")
        serializer = ProductSerializer(products, many=True, context={"request": request})
        return Response(serializer.data, status=200)


# =====================================
#       PUBLIC: PRODUCTS BY STORE
# =====================================
class PublicProductByStoreView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, store_id):
        qs = Product.objects.filter(store_id=store_id, is_available=True).order_by("position", "-created_at")
        category_id = request.query_params.get("category")
        if category_id:
            qs = qs.filter(category_id=category_id)
        serializer = ProductSerializer(qs, many=True, context={"request": request})
        return Response(serializer.data, status=200)


# =====================================
#           OPTION GROUPS
# =====================================
class OptionGroupListCreateView(generics.ListCreateAPIView):
    serializer_class = OptionGroupSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        store = Store.objects.filter(user=self.request.user).first()
        return OptionGroup.objects.filter(product__store=store).order_by("position", "-created_at")

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = OptionGroupSerializer(queryset, many=True)
        return Response(serializer.data, status=200)

    def perform_create(self, serializer):
        product = serializer.validated_data.get("product")
        store = Store.objects.filter(user=self.request.user).first()
        if store is None:
            raise serializers.ValidationError({"store": "User does not have a store"})
        if product.store != store:
            raise serializers.ValidationError({"product": "Product does not belong to this store"})
        serializer.save()

    def create(self, request, *args, **kwargs):
        super().create(request, *args, **kwargs)
        og = OptionGroup.objects.order_by("-created_at").first()
        serializer = OptionGroupSerializer(og)
        return Response(serializer.data, status=201)


class OptionGroupDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = OptionGroupSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        store = Store.objects.filter(user=self.request.user).first()
        return OptionGroup.objects.filter(product__store=store)

    def retrieve(self, request, *args, **kwargs):
        og = self.get_object()
        serializer = OptionGroupSerializer(og)
        return Response(serializer.data, status=200)

    def perform_update(self, serializer):
        product = serializer.validated_data.get("product") or self.get_object().product
        store = Store.objects.filter(user=self.request.user).first()
        if store is None:
            raise serializers.ValidationError({"store": "User does not have a store"})
        if product.store != store:
            raise serializers.ValidationError({"product": "Product does not belong to this store"})
        serializer.save()

    def update(self, request, *args, **kwargs):
        kwargs["partial"] = True
        return super().update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        super().destroy(request, *args, **kwargs)
        return Response(status=204)


# =====================================
#               OPTIONS
# =====================================
class OptionListCreateView(generics.ListCreateAPIView):
    serializer_class = OptionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        store = Store.objects.filter(user=self.request.user).first()
        return Option.objects.filter(option_group__product__store=store).order_by("position", "-created_at")

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = OptionSerializer(queryset, many=True)
        return Response(serializer.data, status=200)

    def perform_create(self, serializer):
        option_group = serializer.validated_data.get("option_group")
        store = Store.objects.filter(user=self.request.user).first()
        if store is None:
            raise serializers.ValidationError({"store": "User does not have a store"})
        if option_group.product.store != store:
            raise serializers.ValidationError({"option_group": "Option group does not belong to this store"})
        serializer.save()

    def create(self, request, *args, **kwargs):
        super().create(request, *args, **kwargs)
        opt = Option.objects.order_by("-created_at").first()
        serializer = OptionSerializer(opt)
        return Response(serializer.data, status=201)


class OptionDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = OptionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        store = Store.objects.filter(user=self.request.user).first()
        return Option.objects.filter(option_group__product__store=store)

    def retrieve(self, request, *args, **kwargs):
        opt = self.get_object()
        serializer = OptionSerializer(opt)
        return Response(serializer.data, status=200)

    def perform_update(self, serializer):
        option_group = serializer.validated_data.get("option_group") or self.get_object().option_group
        store = Store.objects.filter(user=self.request.user).first()
        if store is None:
            raise serializers.ValidationError({"store": "User does not have a store"})
        if option_group.product.store != store:
            raise serializers.ValidationError({"option_group": "Option group does not belong to this store"})
        serializer.save()

    def update(self, request, *args, **kwargs):
        kwargs["partial"] = True
        return super().update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        super().destroy(request, *args, **kwargs)
        return Response(status=204)


# =====================================
#           TEMPLATE GROUPS
# =====================================
class OptionGroupTemplateListCreateView(generics.ListCreateAPIView):
    serializer_class = OptionGroupTemplateSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return OptionGroupTemplate.objects.all().order_by("position", "-created_at")
        store = Store.objects.filter(user=user).first()
        return OptionGroupTemplate.objects.filter(store=store).order_by("position", "-created_at")

    def list(self, request, *args, **kwargs):
        qs = self.get_queryset()
        serializer = OptionGroupTemplateSerializer(qs, many=True)
        return Response(serializer.data, status=200)

    def create(self, request, *args, **kwargs):
        store = Store.objects.filter(user=request.user).first()
        if not store:
            raise serializers.ValidationError({"store": "User does not have a store"})
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        ogt_store = store if not request.user.is_staff else serializer.validated_data.get("store")
        serializer.save(store=ogt_store)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=201, headers=headers)


class OptionGroupTemplateDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = OptionGroupTemplateSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return OptionGroupTemplate.objects.all()
        store = Store.objects.filter(user=user).first()
        return OptionGroupTemplate.objects.filter(store=store)

    def perform_update(self, serializer):
        store = Store.objects.filter(user=self.request.user).first()
        if not self.request.user.is_staff:
            if serializer.instance.store != store:
                raise serializers.ValidationError({"store": "Template does not belong to your store"})
            serializer.save(store=store)
        else:
            serializer.save()

    def update(self, request, *args, **kwargs):
        kwargs["partial"] = True
        return super().update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        super().destroy(request, *args, **kwargs)
        return Response(status=204)


class OptionTemplateListCreateView(generics.ListCreateAPIView):
    serializer_class = OptionTemplateSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return OptionTemplate.objects.all().order_by("position", "-created_at")
        store = Store.objects.filter(user=user).first()
        return OptionTemplate.objects.filter(
            option_group_template__store=store
        ).order_by("position", "-created_at")

    def list(self, request, *args, **kwargs):
        qs = self.get_queryset()
        serializer = OptionTemplateSerializer(qs, many=True)
        return Response(serializer.data, status=200)

    def perform_create(self, serializer):
        store = Store.objects.filter(user=self.request.user).first()
        if not store:
            raise serializers.ValidationError({"store": "User does not have a store"})
        ogt = serializer.validated_data.get("option_group_template")
        if ogt.store != store and not self.request.user.is_staff:
            raise serializers.ValidationError({"option_group_template": "Template group does not belong to your store"})
        serializer.save()

    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)


class OptionTemplateDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = OptionTemplateSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.is_staff:
            return OptionTemplate.objects.all()
        store = Store.objects.filter(user=user).first()
        return OptionTemplate.objects.filter(option_group_template__store=store)

    def perform_update(self, serializer):
        if self.request.user.is_staff:
            serializer.save()
            return
        store = Store.objects.filter(user=self.request.user).first()
        if serializer.instance.option_group_template.store != store:
            raise serializers.ValidationError({"option_group_template": "Template group does not belong to your store"})
        ogt = serializer.validated_data.get("option_group_template")
        if ogt and ogt.store != store:
            raise serializers.ValidationError({"option_group_template": "Template group does not belong to your store"})
        serializer.save()

    def update(self, request, *args, **kwargs):
        kwargs["partial"] = True
        return super().update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        super().destroy(request, *args, **kwargs)
        return Response(status=204)


# =====================================
#       PRODUCT <-> TEMPLATE LINK
# =====================================
class ProductOptionGroupListCreateView(generics.ListCreateAPIView):
    serializer_class = ProductOptionGroupSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        store = Store.objects.filter(user=self.request.user).first()
        return ProductOptionGroup.objects.filter(product__store=store).order_by("position", "-created_at")

    def list(self, request, *args, **kwargs):
        qs = self.get_queryset()
        serializer = ProductOptionGroupSerializer(qs, many=True)
        return Response(serializer.data, status=200)

    def perform_create(self, serializer):
        store = Store.objects.filter(user=self.request.user).first()
        if store is None:
            raise serializers.ValidationError({"store": "User does not have a store"})
        product = serializer.validated_data.get("product")
        if product.store != store:
            raise serializers.ValidationError({"product": "Product does not belong to this store"})
        template = serializer.validated_data.get("option_group_template")
        if template.store != store and not self.request.user.is_staff:
            raise serializers.ValidationError({"option_group_template": "Template does not belong to this store"})
        serializer.save()

    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)


class ProductOptionGroupDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = ProductOptionGroupSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        store = Store.objects.filter(user=self.request.user).first()
        return ProductOptionGroup.objects.filter(product__store=store)

    def update(self, request, *args, **kwargs):
        kwargs["partial"] = True
        return super().update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        super().destroy(request, *args, **kwargs)
        return Response(status=204)
