import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/core/utils/location_utils.dart';
import 'package:smart_food_frontend/core/utils/store_badge_utils.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/data/services/recommendation_service.dart';
import 'package:smart_food_frontend/presentation/widgets/store_list_item.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/address_provider.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';
import 'package:smart_food_frontend/providers/user_provider.dart';
import 'package:smart_food_frontend/providers/favorite_provider.dart';

class StoreSuggestionsScreen extends StatefulWidget {
  const StoreSuggestionsScreen({super.key});

  @override
  State<StoreSuggestionsScreen> createState() => _StoreSuggestionsScreenState();
}

class _StoreSuggestionsScreenState extends State<StoreSuggestionsScreen> {
  bool _loading = true;
  bool _nearOnly = false;
  bool _favOnly = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadData);
  }

  Future<void> _loadData() async {
    final storeP = Provider.of<StoreProvider>(context, listen: false);
    final userP = Provider.of<UserProvider>(context, listen: false);
    final addressP = Provider.of<AddressProvider>(context, listen: false);
    final favP = Provider.of<FavoriteProvider>(context, listen: false);

    await Future.wait([
      if (storeP.stores.isEmpty) storeP.loadStoresPublic(),
      if (userP.user == null) userP.loadUserProfile(),
      if (addressP.addresses.isEmpty) addressP.loadAddresses(),
      favP.loadFavorites(),
    ]);

    if (mounted) {
      setState(() {
        _loading = false;
      });
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF5B7B56)),
        title: const Text(
          "Có thể bạn sẽ thích?",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _suggestionCard(),
            _filterRow(),
            Expanded(
              child: Consumer<StoreProvider>(
                builder: (context, provider, _) {
                  if (_loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final suggestions =
                      _buildSuggestions(provider.stores, userLat, userLng);
                  if (suggestions.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Chưa có quán phù hợp, thử lại sau nhé!",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: suggestions.length,
                      itemBuilder: (_, i) {
                        final store = suggestions[i];
                        final distance = distanceFromUser(store, userLat, userLng);
                        final eta = formatEta(distance);
                        return StoreListItem(
                          store: store,
                          distanceKm: distance,
                          etaText: eta,
                          tags: buildStoreTags(store),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.storeDetail,
                            arguments: store,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<StoreModel> _buildSuggestions(
      List<StoreModel> stores, double? userLat, double? userLng) {
    if (stores.isEmpty) return [];
    final favIds =
        Provider.of<FavoriteProvider>(context, listen: false).favoriteStoreIds;
    var filtered = stores;
    if (_favOnly) {
      filtered = filtered.where((s) => favIds.contains(s.id)).toList();
    }
    if (_nearOnly && userLat != null && userLng != null) {
      filtered = filtered.where((s) {
        final d = distanceFromUser(s, userLat, userLng);
        return d != null && d <= 5;
      }).toList();
    }

    final newestSorted = List<StoreModel>.from(filtered)
      ..sort((a, b) => b.id.compareTo(a.id));
    return _take(newestSorted, start: 0, count: 12);
  }

  List<StoreModel> _take(List<StoreModel> stores,
      {required int start, required int count}) {
    if (stores.isEmpty || start >= stores.length) return [];
    final end = (start + count) > stores.length ? stores.length : start + count;
    return stores.sublist(start, end);
  }

  Widget _suggestionCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Có thể bạn sẽ thích?",
            style: TextStyle(
              color: Color(0xFFE05A3E),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Những món ăn bạn có thể thích, hãy thử ngay nào!\nTâm hồn sẽ được chữa lành khi ta được thoả thích ăn những gì mình muốn, yeah...",
            style: TextStyle(
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterRow() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          _filterChip("Lọc theo", false, () {}),
          const SizedBox(width: 8),
          _filterChip("Gần tôi", _nearOnly, () {
            setState(() => _nearOnly = !_nearOnly);
          }),
          const SizedBox(width: 8),
          _filterChip("Yêu thích", _favOnly, () {
            setState(() => _favOnly = !_favOnly);
          }),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color:
              selected ? const Color(0xFF1F7A52).withOpacity(0.12) : const Color(0xFFF6EDE2),
          border: Border.all(
              color:
                  selected ? const Color(0xFF1F7A52) : const Color(0xFFE0D5C8)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF1F7A52) : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
