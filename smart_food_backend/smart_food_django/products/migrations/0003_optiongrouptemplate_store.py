from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ("stores", "0001_initial"),
        ("products", "0002_templates_productlink"),
    ]

    operations = [
        migrations.AddField(
            model_name="optiongrouptemplate",
            name="store",
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.CASCADE,
                related_name="option_group_templates",
                to="stores.store",
            ),
        ),
    ]

