from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ("products", "0003_optiongrouptemplate_store"),
        ("stores", "0008_storecampaign"),
    ]

    operations = [
        migrations.CreateModel(
            name="ProductPopularity",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("score", models.FloatField(default=0)),
                ("window_start", models.DateTimeField(blank=True, null=True)),
                ("window_end", models.DateTimeField(blank=True, null=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "product",
                    models.OneToOneField(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="popularity",
                        to="products.product",
                    ),
                ),
            ],
            options={
                "db_table": "recommend_product_popularity",
            },
        ),
        migrations.CreateModel(
            name="ProductRecommendation",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("score", models.FloatField(default=0)),
                ("reason", models.CharField(blank=True, max_length=255)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "product",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="user_recommendations",
                        to="products.product",
                    ),
                ),
                (
                    "user",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="recommendations",
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
            options={
                "db_table": "recommend_product_recommendations",
                "ordering": ["-score", "-updated_at"],
                "unique_together": {("user", "product")},
            },
        ),
        migrations.CreateModel(
            name="ProductSimilarity",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("score", models.FloatField(default=0)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "product",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="similarities",
                        to="products.product",
                    ),
                ),
                (
                    "similar_product",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="similar_to",
                        to="products.product",
                    ),
                ),
            ],
            options={
                "db_table": "recommend_product_similarities",
                "ordering": ["-score", "product_id"],
                "unique_together": {("product", "similar_product")},
            },
        ),
        migrations.CreateModel(
            name="UserInteraction",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                (
                    "event",
                    models.CharField(
                        choices=[
                            ("view", "View list"),
                            ("detail_view", "Detail view"),
                            ("add_to_cart", "Add to cart"),
                            ("purchase", "Purchase"),
                            ("review_positive", "Review positive"),
                            ("review_neutral", "Review neutral"),
                            ("review_negative", "Review negative"),
                        ],
                        max_length=32,
                    ),
                ),
                ("value", models.FloatField(default=0)),
                ("weight", models.FloatField(default=0)),
                ("meta", models.JSONField(blank=True, default=dict)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                (
                    "product",
                    models.ForeignKey(
                        blank=True,
                        null=True,
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="interactions",
                        to="products.product",
                    ),
                ),
                (
                    "store",
                    models.ForeignKey(
                        blank=True,
                        null=True,
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="interactions",
                        to="stores.store",
                    ),
                ),
                (
                    "user",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="interactions",
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
            options={
                "db_table": "recommend_user_interactions",
                "ordering": ["-created_at"],
            },
        ),
        migrations.AddIndex(
            model_name="userinteraction",
            index=models.Index(
                fields=["user", "product", "event"],
                name="recommend_u_user_id_75d9ab_idx",
            ),
        ),
        migrations.AddIndex(
            model_name="userinteraction",
            index=models.Index(
                fields=["product", "created_at"],
                name="recommend_u_product__7ce35c_idx",
            ),
        ),
        migrations.AddIndex(
            model_name="userinteraction",
            index=models.Index(
                fields=["user", "created_at"],
                name="recommend_u_user_id_67cf40_idx",
            ),
        ),
        migrations.AddIndex(
            model_name="productsimilarity",
            index=models.Index(
                fields=["product", "-score"], name="recommend_p_product__f3d0ad_idx"
            ),
        ),
    ]
