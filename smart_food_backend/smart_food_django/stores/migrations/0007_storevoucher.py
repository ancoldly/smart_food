from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ("stores", "0006_storeoperatinghour"),
    ]

    operations = [
        migrations.CreateModel(
            name="StoreVoucher",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True, primary_key=True, serialize=False, verbose_name="ID"
                    ),
                ),
                ("code", models.CharField(max_length=50)),
                ("description", models.TextField(blank=True)),
                (
                    "discount_type",
                    models.CharField(
                        choices=[("percent", "Percent"), ("fixed", "Fixed")],
                        default="percent",
                        max_length=10,
                    ),
                ),
                ("discount_value", models.DecimalField(decimal_places=2, max_digits=10)),
                ("min_order_value", models.DecimalField(decimal_places=2, default=0, max_digits=12)),
                (
                    "max_discount_value",
                    models.DecimalField(blank=True, decimal_places=2, max_digits=12, null=True),
                ),
                ("start_date", models.DateTimeField(blank=True, null=True)),
                ("end_date", models.DateTimeField(blank=True, null=True)),
                ("usage_limit", models.PositiveIntegerField(blank=True, null=True)),
                ("used_count", models.PositiveIntegerField(default=0)),
                ("is_active", models.BooleanField(default=True)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "store",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="store_vouchers",
                        to="stores.store",
                    ),
                ),
            ],
            options={
                "db_table": "store_vouchers",
                "ordering": ["-created_at"],
                "unique_together": {("store", "code")},
            },
        ),
    ]

