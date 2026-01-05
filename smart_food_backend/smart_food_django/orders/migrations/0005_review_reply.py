from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0004_review'),
    ]

    operations = [
        migrations.AddField(
            model_name='review',
            name='reply_comment',
            field=models.TextField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='review',
            name='reply_at',
            field=models.DateTimeField(blank=True, null=True),
        ),
    ]
