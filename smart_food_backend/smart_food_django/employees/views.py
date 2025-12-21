from rest_framework import generics, permissions
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Employee
from .serializers import EmployeeSerializer
from stores.models import Store


# ======================================
# LIST + CREATE EMPLOYEE (MERCHANT ONLY)
# ======================================
class EmployeeListCreateView(generics.ListCreateAPIView):
    serializer_class = EmployeeSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get_queryset(self):
        store = Store.objects.filter(user=self.request.user).first()
        return Employee.objects.filter(store=store)

    # LIST (GET)
    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = EmployeeSerializer(queryset, many=True, context={"request": request})
        return Response(serializer.data, status=200)

    # CREATE (POST)
    def perform_create(self, serializer):
        store = Store.objects.filter(user=self.request.user).first()
        serializer.save(store=store)

    def create(self, request, *args, **kwargs):
        super().create(request, *args, **kwargs)
        store = Store.objects.filter(user=request.user).first()
        employee = Employee.objects.filter(store=store).order_by("-created_at").first()
        serializer = EmployeeSerializer(employee, context={"request": request})
        return Response(serializer.data, status=201)


# ======================================
# RETRIEVE / UPDATE / DELETE EMPLOYEE
# ======================================
class EmployeeDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = EmployeeSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get_queryset(self):
        store = Store.objects.filter(user=self.request.user).first()
        return Employee.objects.filter(store=store)

    # GET ONE
    def retrieve(self, request, *args, **kwargs):
        employee = self.get_object()
        serializer = EmployeeSerializer(employee, context={"request": request})
        return Response(serializer.data, status=200)

    # FIX QUAN TRỌNG: luôn gán lại store khi update
    def perform_update(self, serializer):
        store = Store.objects.filter(user=self.request.user).first()
        serializer.save(store=store)

    # UPDATE (PATCH OR PUT)
    def update(self, request, *args, **kwargs):
        partial = True  # CHO PHÉP PATCH DÙ DÙNG PUT
        super().update(request, *args, partial=partial, **kwargs)

        employee = self.get_object()
        serializer = EmployeeSerializer(employee, context={"request": request})
        return Response(serializer.data, status=200)

    # DELETE
    def destroy(self, request, *args, **kwargs):
        super().destroy(request, *args, **kwargs)
        return Response(status=204)


# ======================================
# ADMIN: LIST ALL EMPLOYEES
# ======================================
class AdminEmployeeListView(APIView):
    permission_classes = [permissions.IsAdminUser]

    def get(self, request):
        employees = Employee.objects.all().order_by("-created_at")
        serializer = EmployeeSerializer(employees, many=True, context={"request": request})
        return Response(serializer.data, status=200)
