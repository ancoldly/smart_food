from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    """
    Custom user cho Smart Food — đăng nhập bằng email.
    """

    ROLE_CHOICES = (
        ('customer', 'Customer'),
        ('merchant', 'Merchant'),
        ('shipper', 'Shipper'),
        ('admin', 'Admin'),
    )

    # Email là trường đăng nhập chính
    email = models.EmailField(unique=True, blank=False)

    # Các thông tin mở rộng
    full_name = models.CharField(max_length=120, blank=True)
    phone = models.CharField(max_length=20, blank=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='customer')
    avatar = models.ImageField(upload_to='avatars/', blank=True, null=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    # Cấu hình lại cơ chế login
    USERNAME_FIELD = 'email'         # login bằng email
    REQUIRED_FIELDS = ['username']   # vẫn cần username khi tạo superuser

    class Meta:
        db_table = 'users'
        indexes = [
            models.Index(fields=['email']),
            models.Index(fields=['username']),
            models.Index(fields=['phone']),
        ]

    def __str__(self):
        return f"{self.email} - {self.role}"
