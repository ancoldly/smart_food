from django.urls import path
from .views import (
    EmployeeListCreateView,
    EmployeeDetailView,
    AdminEmployeeListView
)

urlpatterns = [
    # Merchant Routes
    path('', EmployeeListCreateView.as_view(), name="employee-list-create"),
    path('<int:pk>/', EmployeeDetailView.as_view(), name="employee-detail"),

    # Admin Routes
    path('admin/all/', AdminEmployeeListView.as_view(), name="admin-employee-list"),
]
