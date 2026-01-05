import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/draft_cart_model.dart';
import 'package:smart_food_frontend/data/models/order_model.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/data/services/review_service.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/cart_provider.dart';
import 'package:smart_food_frontend/providers/order_provider.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final Set<int> _reviewed = {};
  final Set<int> _checkingReviewed = {};
  final List<String> _filters = const [
    "Đang đến",
    "Lịch sử",
    "Đơn nháp",
    "Đã hủy",
  ];
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final orderP = context.read<OrderProvider>();
      final cartP = context.read<CartProvider>();
      await orderP.loadOrders();
      _prefetchReviewed(orderP.orders);
      await cartP.loadDraftCarts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Đơn hàng",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          _filterRow(),
          const Divider(height: 1),
          Expanded(
            child: _buildTab(),
          ),
        ],
      ),
    );
  }

  Widget _filterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: List.generate(_filters.length, (i) {
          final selected = i == _selected;
          return Padding(
            padding: EdgeInsets.only(right: i == _filters.length - 1 ? 0 : 8),
            child: ChoiceChip(
              label: Text(
                _filters[i],
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF391713),
                  fontWeight: FontWeight.w700,
                ),
              ),
              selected: selected,
              selectedColor: const Color(0xFF1F7A52),
              backgroundColor: const Color(0xFFF6EDE2),
              onSelected: (_) async {
                setState(() => _selected = i);
                if (i == 2) {
                  await context.read<CartProvider>().loadDraftCarts();
                } else {
                  final orderP = context.read<OrderProvider>();
                  await orderP.loadOrders();
                  _prefetchReviewed(orderP.orders);
                }
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTab() {
    if (_selected == 2) return _draftList();
    return RefreshIndicator(
      onRefresh: () async {
        final orderP = context.read<OrderProvider>();
        await orderP.loadOrders();
        _prefetchReviewed(orderP.orders);
      },
      child: Consumer<OrderProvider>(
        builder: (_, orderP, __) {
          final orders = _filteredOrders(orderP.orders);
          _prefetchReviewed(orders);
          if (orderP.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (orders.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 80),
                Center(
                  child: Text(
                    "Chưa có đơn phù hợp",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemBuilder: (_, i) => _orderTile(orders[i]),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: orders.length,
          );
        },
      ),
    );
  }

  List<OrderModel> _filteredOrders(List<OrderModel> all) {
    if (_selected == 0) {
      return all
          .where((o) =>
              o.status == "pending" ||
              o.status == "preparing" ||
              o.status == "delivering")
          .toList();
    }
    if (_selected == 1) {
      return all.where((o) => o.status == "completed").toList();
    }
    if (_selected == 3) {
      return all.where((o) => o.status == "cancelled").toList();
    }
    return all;
  }

  Widget _orderTile(OrderModel o) {
    void openDetail() {
      Navigator.pushNamed(
        context,
        AppRoutes.orderDetail,
        arguments: o,
      );
    }

    return InkWell(
      onTap: openDetail,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E0D7)),
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
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    _absoluteImageUrl(o.storeAvatar).isNotEmpty
                        ? _absoluteImageUrl(o.storeAvatar)
                        : "https://via.placeholder.com/80x80.png?text=Store",
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.store, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              o.storeName.isNotEmpty
                                  ? o.storeName
                                  : "Cửa hàng #${o.storeId}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Color(0xFF2F1C14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _statusChip(o.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        o.storeAddress.isNotEmpty ? o.storeAddress : o.addressLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${o.total.toStringAsFixed(0)}đ (${o.itemCount} món)",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F7A52),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _actionButtons(o, openDetail),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg = Colors.grey.shade200;
    Color fg = Colors.black87;
    String label = status;
    switch (status) {
      case "pending":
        label = "Chờ xác nhận";
        bg = const Color(0xFFFFF2CC);
        fg = const Color(0xFF9A6B00);
        break;
      case "preparing":
        label = "Đang chuẩn bị";
        bg = const Color(0xFFE1F5FE);
        fg = const Color(0xFF0277BD);
        break;
      case "delivering":
        label = "Đang giao";
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
      case "completed":
        label = "Hoàn thành";
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
      case "cancelled":
        label = "Đã hủy";
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _draftList() {
    return RefreshIndicator(
      onRefresh: () => context.read<CartProvider>().loadDraftCarts(),
      child: Consumer<CartProvider>(
        builder: (context, cartP, _) {
          if (cartP.loadingDrafts) {
            return const Center(child: CircularProgressIndicator());
          }
          final drafts = cartP.drafts;
          if (drafts.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 60),
                Center(
                  child: Text(
                    "Chưa có đơn nháp nào",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            );
          }
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: drafts.length,
            itemBuilder: (_, i) => _draftItem(drafts[i]),
          );
        },
      ),
    );
  }

  Widget _draftItem(DraftCartModel draft) {
    final image = _absoluteImageUrl(draft.storeAvatar);
    return InkWell(
      onTap: () {
        // ưu tiên lấy store đầy đủ từ store provider nếu đã load (để có đủ voucher/thông tin)
        final stores = context.read<StoreProvider>().stores;
        final store = stores.firstWhere(
          (s) => s.id == draft.storeId,
          orElse: () => _draftStoreToStoreModel(draft),
        );
        Navigator.pushNamed(
          context,
          AppRoutes.storeDetail,
          arguments: store,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E0D7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                image.isNotEmpty ? image : "https://via.placeholder.com/80x80.png?text=Store",
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    draft.storeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF2F1C14),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    draft.storeAddress.isNotEmpty ? draft.storeAddress : draft.storeCity,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 12.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${draft.total.toStringAsFixed(0)}đ (${draft.itemCount} món)",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F7A52),
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

  StoreModel _draftStoreToStoreModel(DraftCartModel draft) {
    return StoreModel(
      id: draft.storeId,
      category: "",
      storeName: draft.storeName,
      city: draft.storeCity,
      address: draft.storeAddress,
      managerName: "",
      managerPhone: "",
      managerEmail: "",
      latitude: draft.latitude,
      longitude: draft.longitude,
      avatarImage: draft.storeAvatar,
      backgroundImage: null,
      tags: const [],
      status: 1,
      operatingHours: const [],
      campaigns: const [],
      storeVouchers: draft.storeVouchers,
    );
  }

  void _prefetchReviewed(List<OrderModel> orders) {
    for (final o in orders) {
      if (o.status != "completed") continue;
      if (_reviewed.contains(o.id) || _checkingReviewed.contains(o.id)) continue;
      _checkingReviewed.add(o.id);
      ReviewService.fetchByOrder(o.id).then((reviews) {
        _checkingReviewed.remove(o.id);
        if (!mounted) return;
        if (reviews.isNotEmpty) {
          setState(() => _reviewed.add(o.id));
        }
      }).catchError((_) {
        _checkingReviewed.remove(o.id);
      });
    }
  }

  StoreModel _storeFromOrder(OrderModel o) {
    final storeProvider = context.read<StoreProvider>();
    StoreModel? existing;
    for (final s in storeProvider.stores) {
      if (s.id == o.storeId) {
        existing = s;
        break;
      }
    }
    if (existing == null && storeProvider.myStore?.id == o.storeId) {
      existing = storeProvider.myStore;
    }
    if (existing != null) return existing;

    final fallbackVouchers = storeProvider.storeVouchers;

    return StoreModel(
      id: o.storeId,
      category: "",
      storeName: o.storeName,
      city: "",
      address: o.storeAddress,
      managerName: "",
      managerPhone: "",
      managerEmail: "",
      latitude: o.storeLatitude,
      longitude: o.storeLongitude,
      avatarImage: o.storeAvatar,
      backgroundImage: null,
      tags: const [],
      status: 1,
      operatingHours: const [],
      campaigns: const [],
      storeVouchers: fallbackVouchers,
    );
  }

  String _absoluteImageUrl(String url) {
    if (url.isEmpty) return "";
    if (url.startsWith("http")) return url;
    final normalized = url.startsWith("/") ? url : "/$url";
    return "http://10.0.2.2:8000$normalized";
  }

  Widget _actionButtons(OrderModel o, VoidCallback openDetail) {
    final orderProvider = context.read<OrderProvider>();
    final isCompleted = o.status == "completed";
    final alreadyReviewed = _reviewed.contains(o.id);

    if (!isCompleted) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.orderTracking, arguments: o);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F7A52),
                padding: const EdgeInsets.symmetric(vertical: 10),
                minimumSize: const Size(0, 0),
              ),
              child: const Text(
                "Theo dõi đơn",
                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: openDetail,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFFDF5D3),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(vertical: 10),
                minimumSize: const Size(0, 0),
              ),
              child: const Text(
                "Liên hệ shop",
                style: TextStyle(color: Color(0xFF8B6B00), fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      );
    }

    final buttons = <Widget>[];

    if (!alreadyReviewed) {
      buttons.add(
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final reviewed = await Navigator.pushNamed(
                context,
                AppRoutes.reviewOrder,
                arguments: o,
              );
              if (!mounted) return;
              if (reviewed == true) {
                setState(() => _reviewed.add(o.id));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F7A52),
              padding: const EdgeInsets.symmetric(vertical: 10),
              minimumSize: const Size(0, 0),
            ),
            child: const Text(
              "Đánh giá",
              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ),
      );
      buttons.add(const SizedBox(width: 10));
    }

    buttons.add(
      Expanded(
        child: OutlinedButton(
          onPressed: orderProvider.reorderLoading
              ? null
              : () async {
                  final ok = await orderProvider.reorder(o.id);
                  if (!mounted) return;
                  if (ok) {
                    await context.read<CartProvider>().loadCart(o.storeId);
                    if (!mounted) return;
                    Navigator.pushNamed(
                      context,
                      AppRoutes.checkout,
                      arguments: _storeFromOrder(o),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đặt lại thất bại")),
                    );
                  }
                },
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFFDF5D3),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(vertical: 10),
            minimumSize: const Size(0, 0),
          ),
          child: Text(
            orderProvider.reorderLoading ? "Đang xử lý..." : "Đặt lại",
            style: const TextStyle(color: Color(0xFF8B6B00), fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );

    return Row(children: buttons);
  }
}
