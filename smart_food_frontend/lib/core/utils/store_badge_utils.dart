import 'package:smart_food_frontend/data/models/store_campaign_model.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/data/models/store_voucher_model.dart';

/// Build up to two tags for a store: campaign first, then a voucher if available.
List<String> buildStoreTags(StoreModel store) {
  final tags = <String>[];
  final cam = _campaignTag(store);
  final vou = _voucherTag(store);
  if (cam != null) tags.add(cam);
  if (vou != null && tags.length < 2) tags.add(vou);
  if (tags.isEmpty) tags.add("Ship nhanh");
  return tags.take(2).toList();
}

/// First choice for promo label (campaign, else voucher).
String? promoTag(StoreModel store) {
  final cam = _campaignTag(store);
  if (cam != null) return cam;
  return _voucherTag(store) ?? "Ship nhanh";
}

String? _campaignTag(StoreModel store) {
  if (store.campaigns.isEmpty) return null;
  final now = DateTime.now();
  bool isActive(StoreCampaignModel c) {
    final startOk =
        c.startDate == null || _parseDate(c.startDate!)?.isBefore(now) != false;
    final endOk =
        c.endDate == null || _parseDate(c.endDate!)?.isAfter(now) != false;
    return c.isActive && startOk && endOk;
  }

  final active = store.campaigns.firstWhere(
    (c) => isActive(c),
    orElse: () => store.campaigns.first,
  );
  if (!isActive(active)) return null;
  final title = active.title.isNotEmpty ? active.title : "Khuyến mãi";
  return _trim(title, 18);
}

String? _voucherTag(StoreModel store) {
  final list = store.storeVouchers;
  if (list.isEmpty) return null;
  StoreVoucherModel? active;
  for (final v in list) {
    if (v.isActive) {
      active = v;
      break;
    }
  }
  active ??= list.first;
  if (!(active?.isActive ?? false)) return null;
  final title =
      (active?.description.isNotEmpty ?? false) ? active!.description : "Mã giảm giá";
  return _trim(title, 18);
}

DateTime? _parseDate(String iso) {
  try {
    return DateTime.parse(iso);
  } catch (_) {
    return null;
  }
}

String _trim(String text, int maxLen) {
  if (text.length <= maxLen) return text;
  return "${text.substring(0, maxLen)}…";
}
