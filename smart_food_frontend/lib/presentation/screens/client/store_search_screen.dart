import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/core/utils/location_utils.dart';
import 'package:smart_food_frontend/core/utils/store_badge_utils.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/data/services/store_service.dart';
import 'package:smart_food_frontend/data/services/recommendation_service.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/presentation/widgets/store_list_item.dart';
import 'package:smart_food_frontend/providers/address_provider.dart';
import 'package:smart_food_frontend/providers/favorite_provider.dart';

class StoreSearchScreen extends StatefulWidget {
  final String keyword;
  const StoreSearchScreen({super.key, required this.keyword});

  @override
  State<StoreSearchScreen> createState() => _StoreSearchScreenState();
}

class _StoreSearchScreenState extends State<StoreSearchScreen> {
  bool _nearOnly = false;
  bool _favOnly = false;

  Future<List<StoreModel>> _load() {
    return StoreService.fetchStoresByKeyword(keyword: widget.keyword);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<FavoriteProvider>().loadFavorites(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addresses = Provider.of<AddressProvider>(context).addresses;
    final defaultAddress = addresses.isNotEmpty
        ? addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first)
        : null;
    final userLat = defaultAddress?.latitude;
    final userLng = defaultAddress?.longitude;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF5B7B56)),
        title: Text(
          widget.keyword,
          style: const TextStyle(
            color: Color(0xFF5B7B56),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: FutureBuilder<List<StoreModel>>(
        future: _load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Lỗi tải dữ liệu"));
          }
          var data = snapshot.data ?? [];
          final favIds =
              Provider.of<FavoriteProvider>(context, listen: false)
                  .favoriteStoreIds;
          if (_nearOnly && userLat != null && userLng != null) {
            data = data
                .where((s) {
                  final d = distanceFromUser(s, userLat, userLng);
                  return d != null && d <= 5;
                })
                .toList();
          }
          if (_favOnly) {
            data = data.where((s) => favIds.contains(s.id)).toList();
          }

          return Column(
            children: [
              _filterRow(),
              Expanded(
                child: data.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Không tìm thấy quán cho từ khóa "${widget.keyword}"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemBuilder: (_, i) {
                          final s = data[i];
                          final distance = distanceFromUser(s, userLat, userLng);
                          final eta = formatEta(distance);
                          return StoreListItem(
                            store: s,
                            distanceKm: distance,
                            etaText: eta,
                            tags: buildStoreTags(s),
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.storeDetail,
                              arguments: s,
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 0),
                        itemCount: data.length,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterRow() {
    Widget pill(String label, {bool selected = false, VoidCallback? onTap}) {
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : const Color(0xFFF6EDE2),
            border: Border.all(color: const Color(0xFFE0D5C8)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w600)),
              if (label == "Loc theo")
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.keyboard_arrow_down,
                      size: 16, color: Colors.black54),
                ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          pill("Lọc theo"),
          const SizedBox(width: 8),
          pill("Gần tôi", selected: _nearOnly, onTap: () {
            setState(() => _nearOnly = !_nearOnly);
          }),
          const SizedBox(width: 8),
          pill("Yêu thích", selected: _favOnly, onTap: () {
            setState(() => _favOnly = !_favOnly);
          }),
        ],
      ),
    );
  }
}

