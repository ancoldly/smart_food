from django.db import migrations
from django.utils.text import slugify


def populate_slug(apps, schema_editor):
    Category = apps.get_model("categories", "Category")
    for cat in Category.objects.all().order_by("id"):
        if not cat.slug:
            cat.slug = slugify(cat.name) or ""
            cat.save(update_fields=["slug"])


def reverse_func(apps, schema_editor):
    # no-op
    pass


class Migration(migrations.Migration):

    dependencies = [
        ("categories", "0003_unique_slug_nullable"),
    ]

    operations = [
        migrations.RunPython(populate_slug, reverse_func, elidable=True),
    ]

