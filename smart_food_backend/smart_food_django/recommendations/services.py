from typing import Optional

from .models import UserInteraction


DEFAULT_WEIGHTS = {
    "store_view": 0.5,
    "product_view": 1.0,
    "add_to_cart": 2.0,
    "purchase": 5.0,
    "store_favorite": 3.0,
}


def _rating_to_event(rating: Optional[int]) -> str:
    try:
        rating = int(rating)
    except Exception:
        rating = None
    if rating is None:
        return "review_neutral"
    if rating >= 4:
        return "review_positive"
    if rating <= 2:
        return "review_negative"
    return "review_neutral"


def calculate_weight(event: str, value: Optional[float] = None, weight: Optional[float] = None, quantity: int = 1) -> float:
    if weight is not None:
        base = weight
    else:
        base = DEFAULT_WEIGHTS.get(event, 0)
        if event.startswith("review") and value is not None:
            try:
                rating = int(round(float(value)))
                base = REVIEW_WEIGHT_BY_RATING.get(rating, base)
            except Exception:
                pass
    if quantity and quantity > 1:
        base *= quantity
    return float(base)


def log_interaction(user, product, store, event: str, value: float = 0, weight: Optional[float] = None, quantity: int = 1, meta: Optional[dict] = None):
    if not user:
        return None, "missing_user"
    calculated_weight = calculate_weight(event, value=value, weight=weight, quantity=quantity)
    try:
        obj = UserInteraction.objects.create(
            user=user,
            product=product,
            store=store,
            event=event,
            value=value or 0,
            weight=calculated_weight,
            meta=meta or {},
        )
        return obj, None
    except Exception as exc:
        return None, str(exc)


def log_purchase_from_order(order):
    if not order or not order.user:
        return
    try:
        items = order.items.select_related("product").all()
    except Exception:
        items = []
    for item in items:
        product = getattr(item, "product", None)
        log_interaction(
            user=order.user,
            product=product,
            store=order.store,
            event="purchase",
            value=float(item.line_total or 0),
            quantity=getattr(item, "quantity", 1) or 1,
            meta={"order_id": order.id, "order_item_id": item.id},
        )


def log_review_interaction(user, store, product, rating, order_id=None):
    event = _rating_to_event(rating)
    log_interaction(
        user=user,
        product=product,
        store=store,
        event=event,
        value=rating or 0,
        meta={"order_id": order_id},
    )
