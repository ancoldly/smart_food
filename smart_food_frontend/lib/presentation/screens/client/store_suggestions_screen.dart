import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/core/utils/location_utils.dart';
import 'package:smart_food_frontend/core/utils/store_badge_utils.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/presentation/widgets/store_list_item.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/address_provider.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';
import 'package:smart_food_frontend/providers/user_provider.dart';

class StoreSuggestionsScreen extends StatefulWidget {
  const StoreSuggestionsScreen({super.key});

  @override
  State<StoreSuggestionsScreen> createState() => _StoreSuggestionsScreenState();
}

class _StoreSuggestionsScreenState extends State<StoreSuggestionsScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadData);
  }

  Future<void> _loadData() async {
    final storeP = Provider.of<StoreProvider>(context, listen: false);
    final userP = Provider.of<UserProvider>(context, listen: false);
    final addressP = Provider.of<AddressProvider>(context, listen: false);

    await Future.wait([
      if (storeP.stores.isEmpty) storeP.loadStoresPublic(),
      if (userP.user == null) userP.loadUserProfile(),
      if (addressP.addresses.isEmpty) addressP.loadAddresses(),
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
          "Có thể bạn sẽ thích",
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
            Expanded(
              child: Consumer<StoreProvider>(
                builder: (context, provider, _) {
                  if (_loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final suggestions = _buildSuggestions(provider.stores);

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

  List<StoreModel> _buildSuggestions(List<StoreModel> stores) {
    if (stores.isEmpty) return [];
    final newestSorted = List<StoreModel>.from(stores)
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
            "Những món bạn còn đang đỡ, hãy thử ngay nào!\n"
            "Tâm hồn sẽ được chữa lành khi được thỏa thích ăn những gì mình muốn.",
            style: TextStyle(
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}




