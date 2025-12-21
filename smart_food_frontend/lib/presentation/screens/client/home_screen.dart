import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/core/utils/location_utils.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/data/models/store_campaign_model.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/presentation/widgets/home/home_banner.dart';
import 'package:smart_food_frontend/presentation/widgets/home/home_category_toggle.dart';
import 'package:smart_food_frontend/presentation/widgets/home/home_header.dart';
import 'package:smart_food_frontend/presentation/widgets/home/home_no_location.dart';
import 'package:smart_food_frontend/presentation/widgets/home/home_popular_categories.dart';
import 'package:smart_food_frontend/presentation/widgets/home/home_store_sections.dart';
import 'package:smart_food_frontend/providers/address_provider.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';
import 'package:smart_food_frontend/providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  int _currentBanner = 0;
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _loggedCampaignImpressions = {};

  final List<Map<String, String>> popularCats = const [
    {"title": "Trà sữa", "key": "Trà sữa", "image": "assets/categories/Milk_Tea.png"},
    {"title": "Bún/Mì/Phở", "key": "Bún, Mì, Phở", "image": "assets/categories/Noodles&Pho.png"},
    {"title": "Cơm", "key": "Cơm", "image": "assets/categories/Rice_Dishes.png"},
    {"title": "Đồ ăn nhanh", "key": "Đồ ăn nhanh", "image": "assets/categories/Fast_Food.png"},
    {"title": "Cà phê", "key": "Cà phê", "image": "assets/categories/Coffee.png"},
    {"title": "Ăn vặt", "key": "Ăn vặt", "image": "assets/categories/Snacks.png"},
    {"title": "Trà", "key": "Trà", "image": "assets/categories/Tea.png"},
    {"title": "Danh mục", "key": "Danh mục", "image": "assets/images/categories.png"},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    Future.microtask(() async {
      final store = Provider.of<StoreProvider>(context, listen: false);
      final userP = Provider.of<UserProvider>(context, listen: false);
      final addressP = Provider.of<AddressProvider>(context, listen: false);
      await Future.wait([
        store.loadStoresPublic(),
        userP.loadUserProfile(),
        addressP.loadAddresses(),
      ]);
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addresses = Provider.of<AddressProvider>(context).addresses;
    final defaultAddress = addresses.isNotEmpty
        ? addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first)
        : null;
    final userLat = defaultAddress?.latitude;
    final userLng = defaultAddress?.longitude;
    final hasLocation = userLat != null && userLng != null;
    final user = Provider.of<UserProvider>(context, listen: false).user;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      body: SafeArea(
        child: Consumer<StoreProvider>(
          builder: (context, provider, _) {
            final stores = provider.stores;
            final campaignStores = _storesWithActiveCampaigns(stores);
            final bannerItems = _buildCampaignBanners(
              campaignStores,
              context,
            );
            if (bannerItems.isNotEmpty) {
              final idx = _currentBanner.clamp(0, bannerItems.length - 1);
              _logImpression(bannerItems[idx]);
            }
            List<StoreModel> sortedStores = List.from(stores);
            if (userLat != null && userLng != null) {
              sortedStores.sort((a, b) {
                final da = distanceFromUser(a, userLat, userLng) ?? double.maxFinite;
                final db = distanceFromUser(b, userLat, userLng) ?? double.maxFinite;
                return da.compareTo(db);
              });
            }

            if (!hasLocation) {
              return Column(
                children: [
                  HomeHeader(
                    user: user,
                    addresses: addresses,
                    defaultAddress: defaultAddress,
                    searchController: _searchController,
                    onSearchSubmitted: _onSearchSubmitted,
                    onSearchTap: _goToSearchPage,
                  ),
                  Expanded(
                    child: HomeNoLocation(
                      onSaveAddress: _saveAddressFromMap,
                    ),
                  ),
                ],
              );
            }

            final newestSorted = List<StoreModel>.from(stores)..sort((a, b) => b.id.compareTo(a.id));
            final recommended = _take(newestSorted, start: 0, count: 4);
            final nearby = filterNearby(sortedStores, userLat, userLng, 7, take: 4);
            final popularStores = _take(sortedStores, start: 0, count: 8);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: HomeHeader(
                    user: user,
                    addresses: addresses,
                    defaultAddress: defaultAddress,
                    searchController: _searchController,
                    onSearchSubmitted: _onSearchSubmitted,
                    onSearchTap: _goToSearchPage,
                  ),
                ),
                if (!hasLocation) SliverToBoxAdapter(child: _locationNotice()),
                SliverToBoxAdapter(
                  child: HomeBanner(
                    controller: _pageController,
                    currentIndex: _currentBanner,
                    onPageChanged: (i) => _onBannerChanged(i, bannerItems),
                    items: bannerItems,
                  ),
                ),
                const SliverToBoxAdapter(child: HomeCategoryToggle()),
                SliverToBoxAdapter(
                  child: SectionTitle(
                    "Có thể bạn sẽ thích",
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.storeSuggestions),
                  ),
                ),
                SliverToBoxAdapter(
                  child: HorizontalStoreList(
                    data: recommended,
                    userLat: userLat,
                    userLng: userLng,
                  ),
                ),
                SliverToBoxAdapter(
                  child: SectionTitle(
                    "Quán ngon gần bạn, thử xem nào",
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.storeNearby,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: HorizontalStoreList(
                    data: nearby,
                    userLat: userLat,
                    userLng: userLng,
                  ),
                ),
                SliverToBoxAdapter(child: HomePopularCategories(items: popularCats)),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: VerticalStoreList(
                    data: popularStores,
                    userLat: userLat,
                    userLng: userLng,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _saveAddressFromMap(Map data) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final provider = Provider.of<AddressProvider>(context, listen: false);
    final phone = (user?.phone != null && user!.phone!.trim().isNotEmpty)
        ? user.phone!
        : "Số điện thoại mặc định";
    final addrLine = (data["address"] ?? data["street"] ?? "").toString();
    final body = {
      "label": "Địa chỉ của ${user?.fullName ?? user?.username ?? "bạn"}",
      "is_default": true,
      "address_line": addrLine.isNotEmpty ? addrLine : "Địa chỉ mặc định",
      "receiver_name": user?.fullName ?? user?.username ?? "Bạn",
      "receiver_phone": phone,
      "latitude": data["lat"],
      "longitude": data["lng"],
    };
    await provider.addAddress(body);
  }

  Widget _locationNotice() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_off, color: Colors.orange),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chưa có vị trí",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  "Thêm địa chỉ hoặc chọn nhanh vị trí để xem quán gần bạn.",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _saveAddressFromMap({}),
            child: const Text("Thêm nhanh"),
          ),
        ],
      ),
    );
  }

  List<StoreModel> _take(List<StoreModel> stores, {required int start, required int count}) {
    if (stores.isEmpty || start >= stores.length) return [];
    final end = (start + count) > stores.length ? stores.length : start + count;
    return stores.sublist(start, end);
  }

  void _onSearchSubmitted(String value) {
    Navigator.pushNamed(context, AppRoutes.searchInput);
  }

  void _goToSearchPage() {
    Navigator.pushNamed(context, AppRoutes.searchInput);
  }

  void _onBannerChanged(int index, List<HomeBannerItem> items) {
    setState(() => _currentBanner = index);
    if (index >= 0 && index < items.length) {
      _logImpression(items[index]);
    }
  }

  void _logImpression(HomeBannerItem item) {
    if (item.campaignId == null) return;
    if (_loggedCampaignImpressions.contains(item.campaignId)) return;
    _loggedCampaignImpressions.add(item.campaignId!);
    Provider.of<StoreProvider>(context, listen: false)
        .trackCampaignImpression(item.campaignId!);
  }

  List<StoreModel> _storesWithActiveCampaigns(List<StoreModel> stores) {
    return stores.where((s) {
      return s.campaigns.any((c) => _isCampaignActive(c));
    }).toList();
  }

  bool _isCampaignActive(StoreCampaignModel c) {
    if (!c.isActive) return false;
    final now = DateTime.now();
    final startOk =
        c.startDate == null || _parseDate(c.startDate!)?.isBefore(now) != false;
    final endOk =
        c.endDate == null || _parseDate(c.endDate!)?.isAfter(now) != false;
    return startOk && endOk;
  }

  DateTime? _parseDate(String iso) {
    try {
      return DateTime.parse(iso);
    } catch (_) {
      return null;
    }
  }

  List<HomeBannerItem> _buildCampaignBanners(
      List<StoreModel> stores, BuildContext context) {
    final banners = <HomeBannerItem>[];
    final sp = Provider.of<StoreProvider>(context, listen: false);
    const fallbackAssets = [
      "assets/banners/banner1.jpg",
      "assets/banners/banner2.jpg",
      "assets/banners/banner3.jpg",
      "assets/banners/banner4.jpg",
    ];
    for (final s in stores) {
      for (final c in s.campaigns) {
        if (_isCampaignActive(c) && c.bannerUrl.isNotEmpty) {
          banners.add(
            HomeBannerItem(
              c.bannerUrl,
              isNetwork: true,
              campaignId: c.id,
              onTap: () {
                sp.trackCampaignClick(c.id);
                Navigator.pushNamed(
                  context,
                  AppRoutes.storeDetail,
                  arguments: s,
                );
              },
            ),
          );
        }
      }
      if (banners.length >= 5) break;
    }
    if (banners.length < 4) {
      for (final asset in fallbackAssets) {
        banners.add(HomeBannerItem(asset));
        if (banners.length >= 4) break;
      }
    }
    return banners;
  }
}
