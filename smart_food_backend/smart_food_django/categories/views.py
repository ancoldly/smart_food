from rest_framework import generics, permissions
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework import serializers
from rest_framework.permissions import AllowAny

from .models import Category
from .serializers import CategorySerializer
from stores.models import Store


# =============================
# LIST + CREATE CATEGORY
# =============================
class CategoryListCreateView(generics.ListCreateAPIView):
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get_queryset(self):
        store = Store.objects.filter(user=self.request.user).first()
        return Category.objects.filter(store=store).order_by("-created_at")

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = CategorySerializer(queryset, many=True, context={"request": request})
        return Response(serializer.data, status=200)

    def perform_create(self, serializer):
        store = Store.objects.filter(user=self.request.user).first()
        if store is None:
            raise serializers.ValidationError({"store": "User does not have a store"})
        serializer.save(store=store)

    def create(self, request, *args, **kwargs):
        super().create(request, *args, **kwargs)
        store = Store.objects.filter(user=request.user).first()
        category = Category.objects.filter(store=store).order_by("-created_at").first()
        serializer = CategorySerializer(category, context={"request": request})
        return Response(serializer.data, status=201)


# =============================
# RETRIEVE / UPDATE / DELETE
# =============================
class CategoryDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get_queryset(self):
        store = Store.objects.filter(user=self.request.user).first()
        return Category.objects.filter(store=store)

    def retrieve(self, request, *args, **kwargs):
        category = self.get_object()
        serializer = CategorySerializer(category, context={"request": request})
        return Response(serializer.data, status=200)

    def perform_update(self, serializer):
        store = Store.objects.filter(user=self.request.user).first()
        if store is None:
            raise serializers.ValidationError({"store": "User does not have a store"})
        serializer.save(store=store)

    def update(self, request, *args, **kwargs):
        kwargs["partial"] = True  # allow PATCH to be partial
        return super().update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        super().destroy(request, *args, **kwargs)
        return Response(status=204)


# =============================
# ADMIN: LIST ALL CATEGORIES
# =============================
class AdminCategoryListView(APIView):
    permission_classes = [permissions.IsAdminUser]

    def get(self, request):
        categories = Category.objects.all().order_by("-created_at")
        serializer = CategorySerializer(categories, many=True, context={"request": request})
        return Response(serializer.data, status=200)


# =============================
# PUBLIC: LIST CATEGORY BY STORE
# =============================
class PublicCategoryByStoreView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, store_id):
        categories = Category.objects.filter(store_id=store_id, is_active=True).order_by("-created_at")
        serializer = CategorySerializer(categories, many=True, context={"request": request})
        return Response(serializer.data, status=200)
