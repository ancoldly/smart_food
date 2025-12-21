import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';

class StoreHorizontalCard extends StatelessWidget {
  final StoreModel store;
  final double? distanceKm;
  final String? etaText;
  final String? promoText;
  final VoidCallback? onTap;

  const StoreHorizontalCard({
    super.key,
    required this.store,
    this.distanceKm,
    this.etaText,
    this.promoText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = store.avatarImage ?? store.backgroundImage ?? "";
    final distanceText = distanceKm != null
        ? "${distanceKm!.toStringAsFixed(distanceKm! >= 10 ? 0 : 1)} km"
        : null;
    final eta = etaText ?? "";
    final promo = _trimPromo(promoText ?? "Ship nhanh");

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                image.isNotEmpty
                    ? image
                    : "https://via.placeholder.com/120x120.png?text=Store",
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              store.storeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Color(0xFF391713),
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (distanceText != null)
                  _tag(distanceText, const Color(0xFF2E7D32),
                      const Color(0xFFE8F5E9)),
                if (eta.isNotEmpty)
                  _tag(eta, const Color(0xFF1565C0), const Color(0xFFE3F2FD)),
                if (promo != null && promo.isNotEmpty)
                  _tag(promo, Colors.orange, const Color(0xFFFFF2E5)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _trimPromo(String? text) {
    if (text == null) return null;
    const maxLen = 18;
    if (text.length <= maxLen) return text;
    return "${text.substring(0, maxLen)}…";
  }

  Widget _tag(String text, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      constraints: const BoxConstraints(maxWidth: 110),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
