import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/order_model.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/merchant_order_provider.dart';

class MerchantOrdersScreen extends StatefulWidget {
  const MerchantOrdersScreen({super.key});

  @override
  State<MerchantOrdersScreen> createState() => _MerchantOrdersScreenState();
}

class _MerchantOrdersScreenState extends State<MerchantOrdersScreen> {
  final List<_FilterTab> _tabs = const [
    _FilterTab(label: "Đơn mới", statuses: ["pending"]),
    _FilterTab(label: "Đang chuẩn bị", statuses: ["preparing"]),
    _FilterTab(label: "Đang giao", statuses: ["delivering"]),
    _FilterTab(label: "Lịch sử", statuses: ["completed"]),
    _FilterTab(label: "Đã hủy", statuses: ["cancelled"]),
  ];
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MerchantOrderProvider>().loadOrders());
  }

  @override
  Widget build(BuildContext context) {
    final orderP = context.watch<MerchantOrderProvider>();
    final filtered = _filteredOrders(orderP.orders);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Đơn hàng",
          style: TextStyle(
            color: Color(0xFF391713),
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
            child: orderP.loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => orderP.refresh(),
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text(
                              "Chưa có đơn hàng",
                              style: TextStyle(color: Color(0xFF391713)),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(14),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _orderCard(filtered[i]),
                            ),
                          ),
                  ),
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
        children: List.generate(_tabs.length, (i) {
          final selected = i == _selected;
          return Padding(
            padding: EdgeInsets.only(right: i == _tabs.length - 1 ? 0 : 8),
            child: ChoiceChip(
              label: Text(
                _tabs[i].label,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF391713),
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: selected,
              selectedColor: const Color(0xFF2C6B2F),
              backgroundColor: Colors.white,
              onSelected: (_) => setState(() => _selected = i),
            ),
          );
        }),
      ),
    );
  }

  List<OrderModel> _filteredOrders(List<OrderModel> all) {
    if (_tabs[_selected].statuses.isEmpty) return all;
    return all.where((o) => _tabs[_selected].statuses.contains(o.status)).toList();
  }

  Widget _orderCard(OrderModel o) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.orderDetail, arguments: o),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: const Color(0xFFE8E0D7)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _absoluteImageUrl(o.storeAvatar).isNotEmpty
                          ? _absoluteImageUrl(o.storeAvatar)
                          : "https://via.placeholder.com/80x80.png?text=Store",
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.store, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          o.storeName.isNotEmpty ? o.storeName : "Đơn #${o.id}",
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          o.storeAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${o.total.toStringAsFixed(0)}đ (${o.itemCount} món)",
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _statusChip(o.status),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  if (_primaryActionEnabled(o.status))
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C6B2F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _handleStatus(o),
                        child: Text(
                          _primaryLabel(o.status),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  if (_primaryActionEnabled(o.status) && o.status == "pending")
                    const SizedBox(width: 12),
                  if (o.status == "pending")
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFDEBF52)),
                          backgroundColor: const Color(0xFFFFF7D6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _cancel(o),
                        child: const Text(
                          "Hủy đơn",
                          style: TextStyle(color: Color(0xFF82621A), fontWeight: FontWeight.w700),
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

  bool _primaryActionEnabled(String status) => ["pending", "preparing"].contains(status);

  String _primaryLabel(String status) {
    switch (status) {
      case "pending":
        return "Xác nhận";
      case "preparing":
        return "Giao hàng";
      case "delivering":
        return "Đang giao";
      default:
        return "Hoàn thành";
    }
  }

  Future<void> _handleStatus(OrderModel o) async {
    final provider = context.read<MerchantOrderProvider>();
    String? nextStatus;
    switch (o.status) {
      case "pending":
        nextStatus = "preparing";
        break;
    }
    if (nextStatus != null) {
      await provider.updateStatus(o.id, status: nextStatus);
    }
  }

  Future<void> _cancel(OrderModel o) async {
    final provider = context.read<MerchantOrderProvider>();
    await provider.updateStatus(o.id, status: "cancelled");
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
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }

  String _absoluteImageUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    if (url.startsWith("http")) return url;
    final normalized = url.startsWith("/") ? url : "/$url";
    return "http://10.0.2.2:8000$normalized";
  }
}

class _FilterTab {
  final String label;
  final List<String> statuses;
  const _FilterTab({required this.label, required this.statuses});
}
