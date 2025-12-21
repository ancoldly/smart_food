from django.db import migrations, models
import django.db.models.deletion
from django.utils.text import slugify


def create_default_slug(apps, schema_editor):
    StoreTag = apps.get_model("stores", "StoreTag")
    for tag in StoreTag.objects.all():
        if not tag.slug:
            tag.slug = slugify(tag.name or "")
            tag.save()


class Migration(migrations.Migration):

    dependencies = [
        ("stores", "0002_store_avatar_image_alter_store_background_image"),
    ]

    operations = [
        migrations.CreateModel(
            name="StoreTag",
            fields=[
                ("id", models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("name", models.CharField(max_length=100)),
                ("slug", models.SlugField(max_length=120)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "store",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE, related_name="tags", to="stores.store"
                    ),
                ),
            ],
            options={
                "db_table": "store_tags",
                "unique_together": {("store", "slug")},
            },
        ),
        migrations.RunPython(create_default_slug, reverse_code=migrations.RunPython.noop),
    ]
