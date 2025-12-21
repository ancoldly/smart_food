from django.db import migrations, models
import django.utils.timezone


class Migration(migrations.Migration):
    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name="Voucher",
            fields=[
                ("id", models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("code", models.CharField(max_length=50, unique=True)),
                ("title", models.CharField(max_length=255)),
                ("description", models.TextField(blank=True, null=True)),
                (
                    "discount_type",
                    models.CharField(
                        choices=[("percent", "Percent"), ("fixed", "Fixed")], max_length=20
                    ),
                ),
                ("discount_value", models.DecimalField(decimal_places=2, max_digits=10)),
                (
                    "max_discount_amount",
                    models.DecimalField(blank=True, decimal_places=2, max_digits=10, null=True),
                ),
                ("min_order_amount", models.DecimalField(decimal_places=2, default=0, max_digits=10)),
                ("start_at", models.DateTimeField()),
                ("end_at", models.DateTimeField()),
                ("usage_limit_total", models.IntegerField(blank=True, null=True)),
                ("usage_limit_per_user", models.IntegerField(default=1)),
                ("used_count", models.IntegerField(default=0)),
                ("is_active", models.BooleanField(default=True)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
            ],
            options={
                "db_table": "vouchers",
                "ordering": ["-created_at"],
            },
        ),
    ]
