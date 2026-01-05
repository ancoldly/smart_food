import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/order_model.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/shipper_order_provider.dart';

class ShipperHistoryScreen extends StatefulWidget {
  const ShipperHistoryScreen({super.key});

  @override
  State<ShipperHistoryScreen> createState() => _ShipperHistoryScreenState();
}

class _ShipperHistoryScreenState extends State<ShipperHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ShipperOrderProvider>().refresh());
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF9F1E6);
    final provider = context.watch<ShipperOrderProvider>();
    final completed = provider.assigned
        .where((o) => o.status.toLowerCase() == "completed")
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F7A52)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Đơn đã chạy",
          style: TextStyle(
            color: Color(0xFF1F7A52),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF9F1E6),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.refresh(),
              child: completed.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(
                          child: Text(
                            "Chưa có đơn hoàn thành",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) =>
                          _orderCard(completed[index]),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: completed.length,
                    ),
            ),
    );
  }

  Widget _orderCard(OrderModel order) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.orderDetail, arguments: order);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: order.storeAvatar.isNotEmpty
                  ? Image.network(
                      _absoluteImageUrl(order.storeAvatar),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: const Color(0xFFE8E0D7),
                      child: const Icon(Icons.store, color: Colors.black54),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.storeName.isNotEmpty ? order.storeName : "Đơn #${order.id}",
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.storeAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${order.total.toStringAsFixed(0)}đ (${order.itemCount} món)",
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Hoàn thành • Mã #${order.id}",
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _absoluteImageUrl(String url) {
    if (url.isEmpty) return "";
    if (url.startsWith("http")) return url;
    final normalized = url.startsWith("/") ? url : "/$url";
    return "http://10.0.2.2:8000$normalized";
  }
}
