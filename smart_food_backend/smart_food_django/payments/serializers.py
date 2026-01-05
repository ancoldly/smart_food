from rest_framework import serializers
from .models import Payment, Wallet, WalletTransaction


class PaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = "__all__"
        read_only_fields = ("user", "created_at", "updated_at")


class WalletSerializer(serializers.ModelSerializer):
    class Meta:
        model = Wallet
        fields = ["id", "role", "balance", "updated_at"]


class WalletTransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = WalletTransaction
        fields = ["id", "amount", "type", "note", "created_at"]
