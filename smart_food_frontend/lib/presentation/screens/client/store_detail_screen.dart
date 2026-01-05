import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/core/utils/location_utils.dart';
import 'package:smart_food_frontend/data/models/category_model.dart';
import 'package:smart_food_frontend/data/models/product_model.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/data/models/store_voucher_model.dart';
import 'package:smart_food_frontend/data/services/review_service.dart';
import 'package:smart_food_frontend/providers/address_provider.dart';
import 'package:smart_food_frontend/providers/favorite_provider.dart';
import 'package:smart_food_frontend/providers/store_menu_provider.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/presentation/widgets/cart/add_to_cart_bottom_sheet.dart';
import 'package:smart_food_frontend/providers/cart_provider.dart';
import 'package:smart_food_frontend/presentation/screens/client/cart_screen.dart';
import 'package:smart_food_frontend/data/services/recommendation_service.dart';

class StoreDetailScreen extends StatefulWidget {
  final StoreModel store;

  const StoreDetailScreen({super.key, required this.store});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  bool _loading = true;
  int? _selectedCategoryId;
  bool _favLoading = false;
  bool _reviewsLoading = false;
  List<Map<String, dynamic>> _storeReviews = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadData);
  }

  Future<void> _loadData() async {
    await Provider.of<CartProvider>(context, listen: false)
        .loadCart(widget.store.id);
    // ignore: use_build_context_synchronously
    await Provider.of<FavoriteProvider>(context, listen: false).loadFavorites();
    // ignore: use_build_context_synchronously
    await Provider.of<StoreMenuProvider>(context, listen: false)
        .loadMenu(widget.store.id);
    RecommendationService.logEvent(
      storeId: widget.store.id,
      event: "store_view",
    );

    if (mounted) {
      setState(() {
        _loading = false;
        _selectedCategoryId = null;
      });
      _loadStoreReviews(limit: 4);
    }
  }

  Future<void> _loadStoreReviews({int? limit}) async {
    setState(() => _reviewsLoading = true);
    try {
      final data =
          await ReviewService.fetchByStore(widget.store.id, limit: limit);
      if (!mounted) return;
      setState(() {
        _storeReviews = data;
        _reviewsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _reviewsLoading = false);
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
      backgroundColor: const Color(0xFFFFF7EF),
      body: SafeArea(
        child: Builder(builder: (context) {
          final distance = distanceFromUser(widget.store, userLat, userLng);
          final distanceText = _formatDistance(distance);
          final eta = _safeEta(formatEta(distance));
          final menu = Provider.of<StoreMenuProvider>(context);
          final allCategories =
              List<CategoryModel>.from(menu.categoriesFor(widget.store.id))
                ..sort((a, b) => a.id.compareTo(b.id));
          final allProducts =
              List<ProductModel>.from(menu.productsFor(widget.store.id));

          final categories = _selectedCategoryId == null
              ? allCategories
              : allCategories.where((c) => c.id == _selectedCategoryId).toList();
          final products = _selectedCategoryId == null
              ? allProducts
              : allProducts
                  .where((p) => p.categoryId == _selectedCategoryId)
                  .toList();

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _heroSection(eta, distance, distanceText),
                  if (widget.store.storeVouchers.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _voucherCarousel(widget.store.storeVouchers),
                    ),
                  if (!_loading)
                    SliverToBoxAdapter(
                      child: _categoryChips(allCategories),
                    ),
                  if (!_loading)
                    SliverToBoxAdapter(
                      child: _storeReviewsSection(),
                    ),
                  SliverToBoxAdapter(
                    child: _loading
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : _categoriesList(categories, products),
                  ),
                ],
              ),
              _cartFloatingButton(),
            ],
          );
        }),
      ),
    );
  }

  Widget _cartFloatingButton() {
    final cartP = Provider.of<CartProvider>(context);
    final count = cartP.itemCountFor(widget.store.id);
    if (count == 0) return const SizedBox.shrink();
    return Positioned(
      right: 16,
      bottom: 20,
      child: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2E8B57).withOpacity(0.9),
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CartScreen(store: widget.store),
            ),
          );
        },
        icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
        label: Text(
          "Giỏ hàng ($count)",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  SliverAppBar _heroSection(String eta, double? distance, String distanceText) {
    final store = widget.store;
    final image = store.backgroundImage ?? store.avatarImage ?? "";
    final favP = Provider.of<FavoriteProvider>(context);

    return SliverAppBar(
      expandedHeight: 210,
      pinned: true,
      toolbarHeight: 70,
      backgroundColor: const Color(0xFFFFF6EC),
      leadingWidth: 60,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              image.isNotEmpty
                  ? image
                  : "https://via.placeholder.com/600x300.png?text=Store",
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.1)
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 44, height: 44),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: Colors.orange),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: _storeInfoCard(
          eta,
          distanceText,
          isFavorite: favP.isFavorite(widget.store.id),
          onToggleFavorite: _favLoading ? null : _toggleFavorite,
          onOpenInfo: () => _openStoreInfo(distanceText, eta),
        ),
      ),
    );
  }

  Widget _storeInfoCard(
    String eta,
    String distanceText, {
    required bool isFavorite,
    required VoidCallback? onToggleFavorite,
    VoidCallback? onOpenInfo,
  }) {
    final store = widget.store;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              store.avatarImage ??
                  "https://via.placeholder.com/70.png?text=Logo",
              width: 82,
              height: 82,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: onOpenInfo,
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.storeName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                    ),
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
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.timer, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        eta.isNotEmpty ? eta : "30 phút",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      _pill(
                        _statusText(store.status),
                        color: _statusColor(store.status),
                      ),
                      _pill("Ship nhanh"),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints.tightFor(width: 28, height: 28),
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
                size: 22,
              ),
              onPressed: onToggleFavorite,
            ),
          )
        ],
      ),
    );
  }

  Widget _pill(String text, {Color color = Colors.orange}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2E5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _voucherCarousel(List<StoreVoucherModel> vouchers) {
    final active = vouchers.where((v) => v.isActive).toList();
    if (active.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 60,
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 2),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: active.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final v = active[i];
          final title = _voucherTitle(v);
          final subtitle = _voucherSubtitle(v);
          return IntrinsicWidth(
            child: Container(
              constraints: const BoxConstraints(minWidth: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.storeVoucherDetail,
                  arguments: v,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDE0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.card_giftcard,
                          color: Color(0xFF9A1B1D), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFF9A1B1D),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _voucherSubtitle(StoreVoucherModel v) {
    final type = v.discountType == "percent"
        ? "${v.discountValue.toStringAsFixed(0)}% "
        : "${v.discountValue.toStringAsFixed(0)}đ ";
    final minOrder = v.minOrderValue > 0
        ? "Đơn hàng từ ${v.minOrderValue.toStringAsFixed(0)}đ"
        : "Không kèm đơn hàng tối thiểu";
    return minOrder;
  }

  String _voucherTitle(StoreVoucherModel v) {
    final type = v.discountType == "percent"
        ? "Giảm ${v.discountValue.toStringAsFixed(0)}%"
        : "Giảm ${v.discountValue.toStringAsFixed(0)}đ";
    return type;
  }

  Widget _storeReviewsSection() {
    final preview = _storeReviews.take(2).toList();
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text(
                  "Mọi người nhận xét",
                  style: TextStyle(
                    color: Color(0xFFE05A3E),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Color(0xFFE05A3E),
                  ),
                  onPressed: _storeReviews.isEmpty && !_reviewsLoading
                      ? null
                      : () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.storeReviews,
                            arguments: {
                              "storeId": widget.store.id,
                              "storeName": widget.store.storeName,
                            },
                          );
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          if (_reviewsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_storeReviews.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                "Chưa có nhận xét",
                style: TextStyle(color: Colors.black54),
              ),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: preview.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _reviewChip(preview[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _reviewChip(Map<String, dynamic> review) {
    final name = (review["user_name"] ?? "Khách hàng").toString();
    final comment = (review["comment"] ?? "").toString();
    final rating = (review["rating"] ?? 0);
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9DDCC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.isNotEmpty ? comment : "Khách hàng chưa để lại nhận xét",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF3A6A4D),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              Container(width: 1, height: 16, color: Color(0xFFE0D7CC)),
              const SizedBox(width: 6),
              _stars(rating),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stars(num rating) {
    final rounded = rating is int ? rating : rating.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rounded ? Icons.star : Icons.star_border,
          size: 16,
          color: const Color(0xFFFFA726),
        ),
      ),
    );
  }

  String _trim(String text, int maxLen) {
    if (text.length <= maxLen) return text;
    return "${text.substring(0, maxLen)}…";
  }

  Widget _categoryChips(List<CategoryModel> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final cats = [
      const _ChipData(id: null, name: "Tất cả"),
      ...categories.map((c) => _ChipData(id: c.id, name: c.name)),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          scrollDirection: Axis.horizontal,
          itemCount: cats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final item = cats[i];
            final selected = _selectedCategoryId == item.id;
            return _filterChip(
              label: item.name,
              selected: selected,
              onTap: () => setState(
                () => _selectedCategoryId = selected ? null : item.id,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _filterChip(
      {required String label, required bool selected, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1F7A52) : const Color(0xFFFFF7EF),
          border: Border.all(
            color: selected ? const Color(0xFF1F7A52) : const Color(0xFFDDC7A3),
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1F7A52).withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF391713),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _categoriesList(
      List<CategoryModel> categories, List<ProductModel> products) {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("Chưa có danh mục/món cho quán này."),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((c) {
        final items = products.where((p) => p.categoryId == c.id).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                c.name,
                style: const TextStyle(
                  color: Color(0xFF391713),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  "Chưa có món ăn trong danh mục này.",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              )
            else
              Column(
                children: items.map((p) => _productRow(p)).toList(),
              ),
          ],
        );
      }).toList(),
    );
  }

    Widget _productRow(ProductModel p) {
    final isClosed = widget.store.status == 4;
    final priceText = p.discountPrice != null && p.discountPrice! > 0
        ? "${p.discountPrice!.toStringAsFixed(0)} (gốc ${p.price.toStringAsFixed(0)})"
        : p.price.toStringAsFixed(0);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.productDetail,
        arguments: p,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                p.imageUrl ??
                    "https://via.placeholder.com/120x120.png?text=Product",
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
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF391713),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (p.description != null)
                    Text(
                      p.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    "Giá: $priceText",
                    style: const TextStyle(
                      color: Color(0xFF255B36),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: p.isAvailable ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  InkWell(
                    onTap: isClosed
                        ? null
                        : () => showAddToCartBottomSheet(context, p),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            isClosed ? Colors.grey.shade400 : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isClosed ? Icons.lock : Icons.add,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    setState(() => _favLoading = true);
    final favP = Provider.of<FavoriteProvider>(context, listen: false);
    await favP.toggleFavorite(widget.store.id);
    if (mounted) setState(() => _favLoading = false);
  }

  void _openStoreInfo(String distanceText, String eta) {
    Navigator.of(context).pushNamed(
      AppRoutes.storeInfoDetail,
      arguments: {
        "store": widget.store,
        "distanceText": distanceText,
        "etaText": eta,
      },
    );
  }

  String _formatDistance(double? distance) {
    if (distance == null) return "";
    final value = distance >= 10
        ? distance.toStringAsFixed(0)
        : distance.toStringAsFixed(1);
    return "$value km";
  }

  String _safeEta(String eta) => eta.isNotEmpty ? eta : "30 phút";

  String _statusText(int status) {
    return status == 4 ? "Đóng cửa" : "Đang mở";
  }

  Color _statusColor(int status) {
    return status == 4 ? Colors.red : const Color(0xFF2C6B2F);
  }
}

class _ChipData {
  final int? id;
  final String name;
  const _ChipData({required this.id, required this.name});
}

