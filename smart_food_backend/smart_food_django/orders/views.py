from decimal import Decimal
import math

from django.db import transaction
from django.db.models import Sum, Count
from django.utils import timezone
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from address.models import Address
from carts.models import Cart
from carts.serializers import CartSerializer
from stores.models import Store, StoreVoucher
from vouchers.models import Voucher
from shippers.models import Shipper
from notifications.models import Notification
from payments.models import Wallet, WalletTransaction
from .models import Order, OrderItem, OrderItemOption, Review
from .serializers import OrderSerializer, ReviewSerializer
from carts.models import Cart, CartItem, CartItemOption
from products.models import Product, Option, OptionTemplate
from recommendations.services import log_purchase_from_order, log_review_interaction


def _calc_cart_totals(cart: Cart):
    subtotal = Decimal(0)
    for item in cart.items.all():
        subtotal += item.line_total
    return subtotal


def _apply_app_voucher(voucher: Voucher, subtotal: Decimal) -> Decimal:
    if voucher.min_order_amount and subtotal < voucher.min_order_amount:
        return Decimal(0)
    if voucher.discount_type == "percent":
        discount = subtotal * (Decimal(voucher.discount_value) / 100)
    else:
        discount = Decimal(voucher.discount_value)
    if voucher.max_discount_amount:
        discount = min(discount, voucher.max_discount_amount)
    return discount


def _apply_store_voucher(voucher: StoreVoucher, subtotal: Decimal) -> Decimal:
    if subtotal < voucher.min_order_value:
        return Decimal(0)
    if voucher.discount_type == "percent":
        discount = subtotal * (Decimal(voucher.discount_value) / 100)
    else:
        discount = Decimal(voucher.discount_value)
    if voucher.max_discount_value:
        discount = min(discount, voucher.max_discount_value)
    return discount


def _haversine(lat1, lon1, lat2, lon2):
    # khoang cach km
    R = 6371
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2) ** 2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2) ** 2
    c = 2 * math.asin(math.sqrt(a))
    return R * c


class OrderListCreateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        orders = Order.objects.filter(user=request.user).order_by("-created_at")
        data = OrderSerializer(orders, many=True).data
        return Response(data, status=200)

    @transaction.atomic
    def post(self, request):
        user = request.user
        store_id = request.data.get("store_id")
        address_id = request.data.get("address_id")
        payment_method = request.data.get("payment_method") or "cash"
        shipping_fee = Decimal(request.data.get("shipping_fee") or 0)
        app_voucher_code = request.data.get("app_voucher_code")
        store_voucher_id = request.data.get("store_voucher_id")

        if not store_id:
            return Response({"detail": "store_id is required"}, status=400)
        if not address_id:
            return Response({"detail": "address_id is required"}, status=400)

        try:
            store = Store.objects.get(id=store_id)
        except Store.DoesNotExist:
            return Response({"detail": "Store not found"}, status=404)

        address = Address.objects.filter(id=address_id, user=user).first()
        if not address:
            return Response({"detail": "Address not found"}, status=404)

        cart = Cart.objects.filter(user=user, store=store, status="open").prefetch_related(
            "items", "items__options"
        ).first()
        if not cart:
            return Response({"detail": "Cart trống"}, status=400)

        subtotal = _calc_cart_totals(cart)
        discount = Decimal(0)
        app_voucher = None
        store_voucher = None

        if app_voucher_code:
            app_voucher = Voucher.objects.filter(code=app_voucher_code, is_active=True).first()
            if app_voucher and app_voucher.is_valid_now():
                user_used = Order.objects.filter(user=user, app_voucher=app_voucher).count()
                if app_voucher.usage_limit_per_user and user_used >= app_voucher.usage_limit_per_user:
                    app_voucher = None
                elif app_voucher.usage_limit_total is not None and app_voucher.used_count >= app_voucher.usage_limit_total:
                    app_voucher = None
                else:
                    discount += _apply_app_voucher(app_voucher, subtotal)
            else:
                app_voucher = None

        if store_voucher_id:
            store_voucher = StoreVoucher.objects.filter(id=store_voucher_id, store=store, is_active=True).first()
            if store_voucher:
                if store_voucher.usage_limit is not None and store_voucher.used_count >= store_voucher.usage_limit:
                    store_voucher = None
                elif store_voucher.start_date and (store_voucher.end_date and store_voucher.start_date > store_voucher.end_date):
                    store_voucher = None
                else:
                    discount += _apply_store_voucher(store_voucher, subtotal)
            else:
                store_voucher = None

        # luu toa do giao hang va tinh phi ship theo khoang cach
        address_lat = address.latitude
        address_lng = address.longitude
        if (
            store.latitude is not None
            and store.longitude is not None
            and address_lat is not None
            and address_lng is not None
        ):
            distance_km = _haversine(
                store.latitude,
                store.longitude,
                address_lat,
                address_lng,
            )
            base_fee = Decimal(15000)
            per_km_fee = Decimal(7000) * Decimal(distance_km)
            extra_short = Decimal(3000) if distance_km < 2 else Decimal(0)
            shipping_fee = base_fee + per_km_fee + extra_short

        total = subtotal + shipping_fee - discount
        if total < 0:
            total = Decimal(0)

        order = Order.objects.create(
            user=user,
            store=store,
            address_line=address.address_line,
            receiver_name=address.receiver_name,
            receiver_phone=address.receiver_phone,
            address_latitude=address_lat,
            address_longitude=address_lng,
            payment_method=payment_method,
            subtotal=subtotal,
            shipping_fee=shipping_fee,
            discount=discount,
            total=total,
            app_voucher=app_voucher,
            store_voucher=store_voucher,
        )

        for item in cart.items.all():
            order_item = OrderItem.objects.create(
                order=order,
                product=item.product,
                product_name=item.product.name if item.product else "",
                quantity=item.quantity,
                unit_price=item.unit_price,
                line_total=item.line_total,
            )
            for opt in item.options.all():
                OrderItemOption.objects.create(
                    order_item=order_item,
                    name=opt.name,
                    price=opt.price,
                )

        cart.status = "checked_out"
        cart.save(update_fields=["status"])

        if app_voucher:
            app_voucher.used_count = (app_voucher.used_count or 0) + 1
            app_voucher.save(update_fields=["used_count"])
        if store_voucher:
            store_voucher.used_count = (store_voucher.used_count or 0) + 1
            store_voucher.save(update_fields=["used_count"])

        log_purchase_from_order(order)

        if store.user:
            Notification.objects.create(
                user=store.user,
                title="Đơn hàng mới",
                message=f"Bạn có đơn hàng mới #{order.id}",
                order=order,
            )

        data = OrderSerializer(order).data
        return Response(data, status=201)


class OrderDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, pk):
        order = Order.objects.filter(id=pk, user=request.user).first()
        if not order:
            return Response({"detail": "Order not found"}, status=404)
        data = OrderSerializer(order).data
        return Response(data, status=200)


class MerchantOrderListView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        orders = Order.objects.filter(store__user=request.user).order_by("-created_at")
        data = OrderSerializer(orders, many=True).data
        return Response(data, status=200)


class MerchantOrderDetailUpdateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, pk):
        order = Order.objects.filter(id=pk, store__user=request.user).first()
        if not order:
            return Response({"detail": "Order not found"}, status=404)
        return Response(OrderSerializer(order).data, status=200)

    def patch(self, request, pk):
        order = Order.objects.filter(id=pk, store__user=request.user).first()
        if not order:
            return Response({"detail": "Order not found"}, status=404)

        allowed_status = {"pending", "preparing", "cancelled"}
        new_status = request.data.get("status")
        updates = []

        if new_status in allowed_status:
            order.status = new_status
            updates.append("status")

        payment_status = request.data.get("payment_status")
        if payment_status in dict(Order.PAYMENT_STATUS_CHOICES):
            order.payment_status = payment_status
            updates.append("payment_status")

        if updates:
            order.save(update_fields=updates)
            Notification.objects.create(
                user=order.user,
                title="Cập nhật đơn hàng",
                message=f"Đơn #{order.id} đã chuyển sang trạng thái {order.status}",
                order=order,
            )

            if new_status == "preparing":
                online_qs = Shipper.objects.filter(status=4)
                target_shipper = None
                if (
                    order.store
                    and order.store.latitude is not None
                    and order.store.longitude is not None
                ):
                    shippers = list(online_qs)
                    if shippers:
                        shippers.sort(
                            key=lambda s: _haversine(
                                order.store.latitude,
                                order.store.longitude,
                                s.latitude if s.latitude is not None else 0,
                                s.longitude if s.longitude is not None else 0,
                            )
                            if s.latitude is not None and s.longitude is not None
                            else 1e9
                        )
                        target_shipper = shippers[0] if shippers else None
                else:
                    target_shipper = online_qs.first()

                recipients = [target_shipper] if target_shipper else list(online_qs)
                for shp in recipients:
                    Notification.objects.create(
                        user=shp.user,
                        title="Đơn hàng mới",
                        message=f"Có đơn mới #{order.id} cần giao",
                        order=order,
                    )

        return Response(OrderSerializer(order).data, status=200)


class MerchantRevenueView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = Order.objects.filter(store__user=request.user, status="completed")
        total = qs.aggregate(total=Sum("merchant_earning"))["total"] or Decimal(0)
        count = qs.count()
        return Response({"total": total, "count": count}, status=200)


class ShipperAvailableOrdersView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        shipper = Shipper.objects.filter(user=request.user).first()
        qs = Order.objects.filter(status__in=["pending", "preparing"], shipper__isnull=True)

        if shipper and shipper.latitude is not None and shipper.longitude is not None:
            def distance(o: Order):
                if o.store and o.store.latitude is not None and o.store.longitude is not None:
                    return _haversine(
                        shipper.latitude,
                        shipper.longitude,
                        o.store.latitude,
                        o.store.longitude,
                    )
                return 1e9

            sorted_qs = sorted(list(qs), key=distance)
            data = OrderSerializer(sorted_qs, many=True).data
        else:
            data = OrderSerializer(qs, many=True).data
        return Response(data, status=200)


class ShipperMyOrdersView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        shipper = Shipper.objects.filter(user=request.user).first()
        if not shipper:
            return Response({"detail": "Ban chua la shipper"}, status=400)
        qs = Order.objects.filter(shipper=shipper).order_by("-created_at")
        data = OrderSerializer(qs, many=True).data
        return Response(data, status=200)


class ShipperAcceptView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        shipper = Shipper.objects.filter(user=request.user).first()
        if not shipper:
            return Response({"detail": "Ban chua la shipper"}, status=400)
        order = Order.objects.filter(
            id=pk,
            shipper__isnull=True,
            status__in=["pending", "preparing"],
        ).first()
        if not order:
            return Response({"detail": "Khong the nhan don nay"}, status=404)

        order.shipper = shipper
        order.status = "delivering"
        order.save(update_fields=["shipper", "status"])

        Notification.objects.create(
            user=order.user,
            title="Đơn đang giao",
            message=f"Đơn #{order.id} đang được giao bởi shipper",
            order=order,
        )
        if order.store and order.store.user:
            Notification.objects.create(
                user=order.store.user,
                title="Đơn đang giao",
                message=f"Shipper đã nhận đơn #{order.id}",
                order=order,
            )
        return Response(OrderSerializer(order).data, status=200)


class ShipperCompleteView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        shipper = Shipper.objects.filter(user=request.user).first()
        if not shipper:
            return Response({"detail": "Ban chua la shipper"}, status=400)
        order = Order.objects.filter(id=pk, shipper=shipper).first()
        if not order:
            return Response({"detail": "Khong tim thay don"}, status=404)
        if order.status == "completed":
            return Response(OrderSerializer(order).data, status=200)

        order.status = "completed"
        order.payment_status = "paid"
        # chia doanh thu: store nhận 70% giá trị đơn, shipper nhận 60% phí ship
        order.shipper_earning = (order.shipping_fee or Decimal(0)) * Decimal("0.6")
        order.merchant_earning = max(order.total - order.shipping_fee, Decimal(0)) * Decimal("0.7")
        order.save(update_fields=["status", "payment_status", "shipper_earning", "merchant_earning"])

        if order.store and order.store.user:
            merchant_wallet, _ = Wallet.objects.get_or_create(user=order.store.user, role="merchant")
            merchant_wallet.balance = merchant_wallet.balance + order.merchant_earning
            merchant_wallet.save(update_fields=["balance"])
            WalletTransaction.objects.create(
                wallet=merchant_wallet,
                amount=order.merchant_earning,
                type="topup",
                note=f"Doanh thu (70%) đơn #{order.id}",
            )

        if order.shipper and order.shipper.user:
            shipper_wallet, _ = Wallet.objects.get_or_create(user=order.shipper.user, role="shipper")
            shipper_wallet.balance = shipper_wallet.balance + order.shipper_earning
            shipper_wallet.save(update_fields=["balance"])
            WalletTransaction.objects.create(
                wallet=shipper_wallet,
                amount=order.shipper_earning,
                type="topup",
                note=f"Phí ship (60%) đơn #{order.id}",
            )
            if order.payment_method == "cash":
                shipper_wallet.balance = shipper_wallet.balance - order.total
                shipper_wallet.save(update_fields=["balance"])
                WalletTransaction.objects.create(
                    wallet=shipper_wallet,
                    amount=-order.total,
                    type="withdraw",
                    note=f"Tiền mặt đơn #{order.id}",
                )

        Notification.objects.create(
            user=order.user,
            title="Đơn đã giao",
            message=f"Đơn #{order.id} đã được giao thành công",
            order=order,
        )
        if order.store and order.store.user:
            Notification.objects.create(
                user=order.store.user,
                title="Đơn đã giao",
                message=f"Đơn #{order.id} đã hoàn thành",
                order=order,
            )
        return Response(OrderSerializer(order).data, status=200)


class ShipperRevenueView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        shipper = Shipper.objects.filter(user=request.user).first()
        if not shipper:
            return Response({"detail": "Ban chua la shipper"}, status=400)
        qs = Order.objects.filter(shipper=shipper, status="completed")
        total = qs.aggregate(total=Sum("shipper_earning"))["total"] or Decimal(0)
        count = qs.count()
        return Response({"total": total, "count": count}, status=200)


class ShipperLeaderboardView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        shipper = Shipper.objects.filter(user=request.user).first()
        now = timezone.now()
        month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

        base_qs = (
            Order.objects.filter(
                status="completed",
                shipper__isnull=False,
                created_at__gte=month_start,
            )
            .values("shipper", "shipper__full_name")
            .annotate(count=Count("id"))
            .order_by("-count")
        )

        leaderboard = list(base_qs[:10])
        items = []
        for idx, item in enumerate(leaderboard, start=1):
            items.append(
                {
                    "rank": idx,
                    "shipper_id": item["shipper"],
                    "name": item["shipper__full_name"] or "",
                    "count": item["count"],
                }
            )

        my_count = 0
        my_rank = None
        if shipper:
            my_count = (
                Order.objects.filter(
                    status="completed",
                    shipper=shipper,
                    created_at__gte=month_start,
                ).count()
            )
            rank_list = list(base_qs)
            for idx, item in enumerate(rank_list, start=1):
                if item["shipper"] == shipper.id:
                    my_rank = idx
                    break

        data = {
            "items": items,
            "my": {
                "count": my_count,
                "rank": my_rank,
                "name": shipper.full_name if shipper else "",
            },
            "updated_at": now,
        }
        return Response(data, status=200)


class ReviewView(APIView):
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get(self, request):
        order_id = request.query_params.get("order")
        store_id = request.query_params.get("store")
        product_id = request.query_params.get("product")
        limit = request.query_params.get("limit")

        # user-specific reviews by order (must own the order)
        if order_id:
            if not request.user.is_authenticated:
                return Response({"detail": "Authentication required"}, status=401)
            order = Order.objects.filter(id=order_id, user=request.user).first()
            if not order:
                return Response({"detail": "Order not found"}, status=404)
            reviews = Review.objects.filter(order=order)
            data = ReviewSerializer(reviews, many=True).data
            return Response(data, status=200)

        # public reviews by store/product
        if not store_id and not product_id:
            return Response({"detail": "store or product is required"}, status=400)
        qs = Review.objects.all()
        if store_id:
            qs = qs.filter(store_id=store_id)
        if product_id:
            qs = qs.filter(product_id=product_id)
        if limit:
            try:
                qs = qs[: int(limit)]
            except Exception:
                pass
        data = ReviewSerializer(qs.select_related("product", "user"), many=True).data
        return Response(data, status=200)

    @transaction.atomic
    def post(self, request):
        order_id = request.data.get("order_id")
        store_rating = request.data.get("store_rating")
        store_comment = request.data.get("store_comment")
        product_reviews = request.data.get("product_reviews", [])

        order = Order.objects.filter(id=order_id, user=request.user).first()
        if not order:
            return Response({"detail": "Order not found"}, status=404)
        if order.status != "completed":
            return Response({"detail": "Chỉ đánh giá đơn đã hoàn thành"}, status=400)

        created = []
        if store_rating:
            Review.objects.update_or_create(
                user=request.user,
                order=order,
                store=order.store,
                product=None,
                defaults={"rating": store_rating, "comment": store_comment},
            )
            log_review_interaction(
                user=request.user,
                store=order.store,
                product=None,
                rating=store_rating,
                order_id=order.id,
            )
        for pr in product_reviews:
            pid = pr.get("product_id")
            rating = pr.get("rating")
            comment = pr.get("comment")
            if not pid or not rating:
                continue
            product = None
            try:
                from products.models import Product

                product = Product.objects.filter(id=pid).first()
            except Exception:
                product = None
            Review.objects.update_or_create(
                user=request.user,
                order=order,
                store=order.store,
                product=product,
                defaults={"rating": rating, "comment": comment},
            )
            log_review_interaction(
                user=request.user,
                store=order.store,
                product=product,
                rating=rating,
                order_id=order.id,
            )
        return Response({"detail": "Đã lưu đánh giá"}, status=200)


class ReorderView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @transaction.atomic
    def post(self, request, pk):
        order = (
            Order.objects.filter(id=pk, user=request.user)
            .prefetch_related("items", "items__product", "items__options", "store")
            .first()
        )
        if not order:
            return Response({"detail": "Order not found"}, status=404)
        if order.status != "completed":
            return Response({"detail": "Chỉ đặt lại đơn đã hoàn thành"}, status=400)

        cart, _ = Cart.objects.get_or_create(user=request.user, store=order.store, status="open")
        cart.items.all().delete()

        for it in order.items.all():
            product = it.product
            if not product:
                continue
            cart_item = CartItem.objects.create(
                cart=cart,
                product=product,
                quantity=it.quantity,
                unit_price=it.unit_price,
                note="",
            )
            for opt in it.options.all():
                CartItemOption.objects.create(
                    cart_item=cart_item,
                    option=None,
                    option_template=None,
                    name=opt.name,
                    price=opt.price,
                )

        return Response({"detail": "Đã tạo lại giỏ hàng"}, status=200)


class MerchantReviewListView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        store = Store.objects.filter(user=request.user).first()
        if not store:
            return Response({"detail": "Khong tim thay cua hang"}, status=404)
        product_id = request.query_params.get("product")
        qs = Review.objects.filter(store=store).select_related("product", "user")
        if product_id:
            qs = qs.filter(product_id=product_id)
        data = ReviewSerializer(qs, many=True).data
        counts = {i: 0 for i in range(1, 6)}
        for r in qs:
            try:
                star = int(r.rating)
            except Exception:
                continue
            if 1 <= star <= 5:
                counts[star] = counts.get(star, 0) + 1
        total = sum(counts.values())
        avg = (sum(k * v for k, v in counts.items()) / total) if total else 0
        summary = {"avg": avg, "total": total, "counts": counts}
        return Response({"items": data, "summary": summary}, status=200)


class ReviewReplyView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        store = Store.objects.filter(user=request.user).first()
        if not store:
            return Response({"detail": "Khong tim thay cua hang"}, status=404)
        review = Review.objects.filter(id=pk, store=store).first()
        if not review:
            return Response({"detail": "Review not found"}, status=404)
        reply = request.data.get("reply")
        if not reply:
            return Response({"detail": "reply is required"}, status=400)
        review.reply_comment = reply
        review.reply_at = timezone.now()
        review.save(update_fields=["reply_comment", "reply_at"])
        return Response(ReviewSerializer(review).data, status=200)
