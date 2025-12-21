import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/core/utils/location_utils.dart';
import 'package:smart_food_frontend/core/utils/store_badge_utils.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/presentation/widgets/store_list_item.dart';
import 'package:smart_food_frontend/providers/address_provider.dart';
import 'package:smart_food_frontend/providers/favorite_provider.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final favP = Provider.of<FavoriteProvider>(context, listen: false);
    final storeP = Provider.of<StoreProvider>(context, listen: false);
    if (storeP.stores.isEmpty) {
      await storeP.loadStoresPublic();
    }
    await favP.loadFavorites();
    if (mounted) {
      setState(() => _loading = false);
    }
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
      body: SafeArea(
        child: Consumer2<FavoriteProvider, StoreProvider>(
          builder: (context, favP, storeP, _) {
            final favIds = favP.favoriteStoreIds.toSet();
            List stores =
                storeP.stores.where((s) => favIds.contains(s.id)).toList();

            if (_nearOnly && userLat != null && userLng != null) {
              stores = stores.where((s) {
                final d = distanceFromUser(s, userLat, userLng);
                return d != null && d <= 5;
              }).toList();
            }

            if (_loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (stores.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Chưa có cửa hàng yêu thích.",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              );
            }

            return Column(
              children: [
                _header(),
                _filterRow(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: stores.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 0),
                      itemBuilder: (_, i) {
                        final s = stores[i];
                        final distance =
                            distanceFromUser(s, userLat, userLng);
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
                          isFavorite: true,
                          onToggleFavorite: () async {
                            final favP = Provider.of<FavoriteProvider>(
                                context,
                                listen: false);
                            await favP.toggleFavorite(s.id);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _nearOnly = false;

  Widget _header() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: const Text(
        "Yêu thích",
        style: TextStyle(
          color: Color(0xFF5B7B56),
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _filterRow() {
    Widget pill(String label,
        {bool selected = false, VoidCallback? onTap}) {
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : const Color(0xFFF6EDE2),
            border: Border.all(color: const Color(0xFFE0D5C8)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (label == "Lọc theo")
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.black54,
                  ),
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
          pill(
            "Tất cả",
            selected: !_nearOnly,
            onTap: () {
              setState(() => _nearOnly = false);
            },
          ),
          const SizedBox(width: 8),
          pill(
            "Gần tôi",
            selected: _nearOnly,
            onTap: () {
              setState(() => _nearOnly = !_nearOnly);
            },
          ),
        ],
      ),
    );
  }
}



