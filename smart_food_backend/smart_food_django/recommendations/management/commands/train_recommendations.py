import math
from collections import defaultdict
from datetime import timedelta

from django.core.management.base import BaseCommand
from django.db import transaction
from django.utils import timezone

from products.models import Product
from recommendations.models import (
    UserInteraction,
    ProductRecommendation,
    ProductSimilarity,
    ProductPopularity,
)


class Command(BaseCommand):
    help = "Huấn luyện gợi ý implicit đơn giản (item-sim + độ phổ biến)"

    def add_arguments(self, parser):
        parser.add_argument("--days", type=int, default=90, help="Khoảng ngày lấy log tương tác")
        parser.add_argument("--topk", type=int, default=50, help="Số gợi ý tối đa lưu cho mỗi user")
        parser.add_argument("--similar-topk", type=int, default=20, help="Số sản phẩm tương tự lưu cho mỗi sản phẩm")
        parser.add_argument("--half-life", type=int, default=45, help="Half-life ngày cho hệ số suy giảm theo thời gian")

    def handle(self, *args, **options):
        days = options["days"]
        topk = options["topk"]
        similar_topk = options["similar_topk"]
        half_life = options["half_life"]

        now = timezone.now()
        start_time = now - timedelta(days=days)
        interactions = (
            UserInteraction.objects.filter(created_at__gte=start_time, product__isnull=False)
            .select_related("product")
            .only("user_id", "product_id", "weight", "created_at")
        )

        user_items = defaultdict(lambda: defaultdict(float))
        popularity = defaultdict(float)

        def decay_factor(ts):
            if not ts:
                return 1.0
            age_days = max((now - ts).days, 0)
            if half_life <= 0:
                return 1.0
            return math.exp(-age_days * math.log(2) / half_life)

        for ui in interactions:
            w = float(ui.weight or 0)
            if w == 0:
                continue
            decay = decay_factor(ui.created_at)
            score = w * decay
            user_items[ui.user_id][ui.product_id] += score
            if score > 0:
                popularity[ui.product_id] += score

        # Tính similarity theo đồng xuất hiện
        co_counts = defaultdict(lambda: defaultdict(float))
        for items in user_items.values():
            products = list(items.items())
            for i in range(len(products)):
                pid_i, w_i = products[i]
                for j in range(i + 1, len(products)):
                    pid_j, w_j = products[j]
                    score = min(w_i, w_j)
                    co_counts[pid_i][pid_j] += score
                    co_counts[pid_j][pid_i] += score

        similarities = {}
        for pid, neighbours in co_counts.items():
            top = sorted(neighbours.items(), key=lambda x: x[1], reverse=True)[:similar_topk]
            similarities[pid] = top

        # Sinh gợi ý cho từng user
        user_recs = defaultdict(list)
        for user_id, items in user_items.items():
            candidate_scores = defaultdict(float)
            for pid, base_w in items.items():
                for neighbour_pid, sim_score in similarities.get(pid, []):
                    if neighbour_pid in items:
                        continue
                    candidate_scores[neighbour_pid] += base_w * sim_score
            top_candidates = sorted(
                candidate_scores.items(), key=lambda x: x[1], reverse=True
            )[:topk]
            user_recs[user_id] = top_candidates

        # Chuẩn bị dữ liệu DB
        product_map = Product.objects.in_bulk(set(popularity.keys()) | set(co_counts.keys()))

        rec_models = []
        for user_id, recs in user_recs.items():
            for pid, score in recs:
                if pid not in product_map:
                    continue
                rec_models.append(
                    ProductRecommendation(
                        user_id=user_id,
                        product_id=pid,
                        score=float(score),
                        reason="item_similarity",
                    )
                )

        sim_models = []
        for pid, neighbours in similarities.items():
            for neighbour_pid, score in neighbours:
                if pid == neighbour_pid:
                    continue
                if pid not in product_map or neighbour_pid not in product_map:
                    continue
                sim_models.append(
                    ProductSimilarity(
                        product_id=pid,
                        similar_product_id=neighbour_pid,
                        score=float(score),
                    )
                )

        pop_models = []
        for pid, score in popularity.items():
            if pid not in product_map:
                continue
            pop_models.append(
                ProductPopularity(
                    product_id=pid,
                    score=float(score),
                    window_start=start_time,
                    window_end=now,
                )
            )

        with transaction.atomic():
            ProductRecommendation.objects.all().delete()
            ProductSimilarity.objects.all().delete()
            ProductPopularity.objects.all().delete()
            if rec_models:
                ProductRecommendation.objects.bulk_create(rec_models, batch_size=500)
            if sim_models:
                ProductSimilarity.objects.bulk_create(sim_models, batch_size=500)
            if pop_models:
                ProductPopularity.objects.bulk_create(pop_models, batch_size=500)

        self.stdout.write(
            self.style.SUCCESS(
                f"Đã huấn luyện: {len(rec_models)} gợi ý, "
                f"{len(sim_models)} cặp tương tự, {len(pop_models)} sản phẩm phổ biến."
            )
        )
