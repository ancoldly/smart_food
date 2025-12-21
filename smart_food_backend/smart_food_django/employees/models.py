from django.db import models
from django.conf import settings
from stores.models import Store


class Employee(models.Model):
    ROLE_CHOICES = (
        ("staff", "Nhân viên"),
        ("cashier", "Thu ngân"),
        ("manager", "Quản lý ca"),
        ("delivery", "Nhân viên giao hàng nội bộ"),
    )

    STATUS_CHOICES = (
        (1, "Đang hoạt động"),
        (2, "Tạm dừng"),
        (3, "Đã nghỉ việc"),
    )

    store = models.ForeignKey(
        Store,
        on_delete=models.CASCADE,
        related_name="employees"
    )

    full_name = models.CharField(max_length=255)
    phone = models.CharField(max_length=20)
    email = models.CharField(max_length=255, blank=True, null=True)

    role = models.CharField(max_length=50, choices=ROLE_CHOICES, default="staff")
    status = models.IntegerField(choices=STATUS_CHOICES, default=1)

    avatar_image = models.ImageField(upload_to="employee_avatar/", null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.full_name} - {self.store.store_name}"

    class Meta:
        db_table = "employees"
        ordering = ["-created_at"]
