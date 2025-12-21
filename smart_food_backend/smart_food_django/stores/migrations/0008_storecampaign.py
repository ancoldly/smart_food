from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ("stores", "0007_storevoucher"),
    ]

    operations = [
        migrations.CreateModel(
            name="StoreCampaign",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True, primary_key=True, serialize=False, verbose_name="ID"
                    ),
                ),
                ("title", models.CharField(max_length=255)),
                ("description", models.TextField(blank=True)),
                ("banner_url", models.URLField(blank=True)),
                ("start_date", models.DateTimeField(blank=True, null=True)),
                ("end_date", models.DateTimeField(blank=True, null=True)),
                ("budget", models.DecimalField(decimal_places=2, default=0, max_digits=14)),
                ("impressions", models.PositiveIntegerField(default=0)),
                ("clicks", models.PositiveIntegerField(default=0)),
                ("is_active", models.BooleanField(default=True)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "store",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="campaigns",
                        to="stores.store",
                    ),
                ),
            ],
            options={
                "db_table": "store_campaigns",
                "ordering": ["-created_at"],
            },
        ),
    ]

