import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';

class StoreListItem extends StatelessWidget {
  final StoreModel store;
  final double? distanceKm;
  final String? etaText;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final List<String> tags;

  const StoreListItem({
    super.key,
    required this.store,
    this.distanceKm,
    this.etaText,
    this.onTap,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.tags = const [],
  });

  @override
  Widget build(BuildContext context) {
    final image = store.avatarImage ?? store.backgroundImage ?? "";
    final distanceText = distanceKm != null
        ? "${distanceKm!.toStringAsFixed(distanceKm! >= 10 ? 0 : 1)} km"
        : "";
    final eta = etaText ?? "";

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFF0E7DB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                image.isNotEmpty
                    ? image
                    : "https://via.placeholder.com/90x90.png?text=Store",
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          store.storeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF391713),
                          ),
                        ),
                      ),
                      if (onToggleFavorite != null)
                        GestureDetector(
                          onTap: () => onToggleFavorite?.call(),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6, right: 2),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                              size: 26,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      const Text(
                        "4.8",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.place, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        distanceText,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.timer, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        eta.isNotEmpty ? eta : "30 phút",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: (tags.isEmpty ? const ["Ship nhanh"] : tags)
                        .map(
                          (t) => ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 130),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF2E5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                t,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
