from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("orders", "0002_order_merchant_earning_order_shipper_and_more"),
    ]

    operations = [
        migrations.AddField(
            model_name="order",
            name="address_latitude",
            field=models.FloatField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name="order",
            name="address_longitude",
            field=models.FloatField(blank=True, null=True),
        ),
    ]
