from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("stores", "0003_storetag"),
    ]

    operations = [
        migrations.AlterField(
            model_name="storetag",
            name="slug",
            field=models.SlugField(blank=True, max_length=120),
        ),
    ]
