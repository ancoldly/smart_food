import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/presentation/widgets/store_horizontal_card.dart';
import 'package:smart_food_frontend/presentation/widgets/store_list_item.dart';
import 'package:smart_food_frontend/core/utils/location_utils.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/core/utils/store_badge_utils.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const SectionTitle(this.text, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF391713),
            ),
          ),
          const Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: const Icon(Icons.arrow_forward,
                  size: 18, color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}

class HorizontalStoreList extends StatelessWidget {
  final List<StoreModel> data;
  final double? userLat;
  final double? userLng;

  const HorizontalStoreList({
    super.key,
    required this.data,
    required this.userLat,
    required this.userLng,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = data[index];
          final distance = distanceFromUser(item, userLat, userLng);
          final etaText = formatEta(distance);
          final promo = promoTag(item);
          return StoreHorizontalCard(
            store: item,
            distanceKm: distance,
            etaText: etaText,
            promoText: promo,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.storeDetail,
              arguments: item,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: data.length,
      ),
    );
  }
}

class VerticalStoreList extends StatelessWidget {
  final List<StoreModel> data;
  final double? userLat;
  final double? userLng;

  const VerticalStoreList({
    super.key,
    required this.data,
    required this.userLat,
    required this.userLng,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: data
          .map(
            (s) => StoreListItem(
              store: s,
              distanceKm: distanceFromUser(s, userLat, userLng),
              etaText: formatEta(distanceFromUser(s, userLat, userLng)),
              tags: buildStoreTags(s),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.storeDetail,
                arguments: s,
              ),
            ),
          )
          .toList(),
    );
  }
}
