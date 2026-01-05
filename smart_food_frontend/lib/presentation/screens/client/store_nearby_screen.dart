import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/core/utils/location_utils.dart';
import 'package:smart_food_frontend/core/utils/store_badge_utils.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/data/services/recommendation_service.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/presentation/widgets/store_list_item.dart';
import 'package:smart_food_frontend/providers/address_provider.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';
import 'package:smart_food_frontend/providers/user_provider.dart';

class StoreNearbyScreen extends StatefulWidget {
  const StoreNearbyScreen({super.key});

  @override
  State<StoreNearbyScreen> createState() => _StoreNearbyScreenState();
}

class _StoreNearbyScreenState extends State<StoreNearbyScreen> {
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
          "Quán ngon gần bạn",
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
            _infoCard(userLat: userLat, userLng: userLng),
            Expanded(
              child: Consumer<StoreProvider>(
                builder: (context, provider, _) {
                  if (_loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final nearby = _buildNearby(provider.stores, userLat, userLng);
                  if (nearby.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Chưa có dữ liệu, thử tải lại nhé!",
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
                      itemCount: nearby.length,
                      itemBuilder: (_, i) {
                        final store = nearby[i];
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

  List<StoreModel> _buildNearby(
      List<StoreModel> stores, double? userLat, double? userLng) {
    if (stores.isEmpty) return [];
    final list = List<StoreModel>.from(stores);

    if (userLat != null && userLng != null) {
      list.sort((a, b) {
        final da = distanceFromUser(a, userLat, userLng) ?? double.maxFinite;
        final db = distanceFromUser(b, userLat, userLng) ?? double.maxFinite;
        return da.compareTo(db);
      });
    } else {
      list.sort((a, b) => b.id.compareTo(a.id));
    }

    return _take(list, start: 0, count: 20);
  }

  List<StoreModel> _take(List<StoreModel> stores,
      {required int start, required int count}) {
    if (stores.isEmpty || start >= stores.length) return [];
    final end = (start + count) > stores.length ? stores.length : start + count;
    return stores.sublist(start, end);
  }

  Widget _infoCard({double? userLat, double? userLng}) {
    final hasLocation = userLat != null && userLng != null;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quán ăn ngon gần bạn nè, quá đã luôn",
            style: TextStyle(
              color: Color(0xFFE05A3E),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasLocation
                ? "Còn gì tuyệt vời hơn khi món ăn ngon gần chúng ta, ưu đãi phí ship, thời gian vận chuyển nhanh, gấp nào..."
                : "Chưa có vị trí. Thêm địa chỉ để sắp xếp quán gần bạn.",
            style: const TextStyle(
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          if (!hasLocation)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.selectLocation);
                },
                child: const Text("Chọn địa chỉ"),
              ),
            ),
        ],
      ),
    );
  }
}






