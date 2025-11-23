from django.urls import path
from .views import (
    PaymentListCreateView,
    PaymentDetailView,
    SetDefaultPaymentView
)

urlpatterns = [
    path("", PaymentListCreateView.as_view(), name="payment-list"),
    path("<int:pk>/", PaymentDetailView.as_view(), name="payment-detail"),
    path("<int:pk>/set-default/", SetDefaultPaymentView.as_view(), name="payment-set-default"),
]
