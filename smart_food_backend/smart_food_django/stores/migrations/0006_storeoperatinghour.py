from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ("stores", "0005_alter_storetag_id_favoritestore"),
    ]

    operations = [
        migrations.CreateModel(
            name="StoreOperatingHour",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True, primary_key=True, serialize=False, verbose_name="ID"
                    ),
                ),
                ("day_of_week", models.PositiveSmallIntegerField()),
                ("open_time", models.TimeField(blank=True, null=True)),
                ("close_time", models.TimeField(blank=True, null=True)),
                ("is_closed", models.BooleanField(default=True)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "store",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="operating_hours",
                        to="stores.store",
                    ),
                ),
            ],
            options={
                "db_table": "store_operating_hours",
                "ordering": ["day_of_week"],
                "unique_together": {("store", "day_of_week")},
            },
        ),
    ]

