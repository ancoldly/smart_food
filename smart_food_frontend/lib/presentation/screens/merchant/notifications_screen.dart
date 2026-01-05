import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/order_model.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/merchant_order_provider.dart';
import 'package:smart_food_frontend/providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final notifP = context.read<NotificationProvider>();
      final orderP = context.read<MerchantOrderProvider>();
      if (orderP.orders.isEmpty) {
        await orderP.loadOrders();
      }
      await notifP.fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifP = context.watch<NotificationProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Thông báo",
          style: TextStyle(color: Color(0xFF2C6B2F), fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => notifP.fetchNotifications(),
        child: notifP.loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(14),
                itemBuilder: (_, i) {
                  final n = notifP.items[i];
                  return ListTile(
                    onTap: () {
                      if (!n.isRead) notifP.markAsRead(n.id);
                      if (n.orderId != null) {
                        OrderModel? order;
                        try {
                          order = context
                              .read<MerchantOrderProvider>()
                              .orders
                              .firstWhere((o) => o.id == n.orderId);
                        } catch (_) {}
                        if (order != null) {
                          Navigator.pushNamed(context, AppRoutes.orderDetail, arguments: order);
                        }
                      }
                    },
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: CircleAvatar(
                      backgroundColor: n.isRead ? const Color(0xFFE8E0D7) : const Color(0xFF2C6B2F),
                      child: const Icon(Icons.notifications, color: Colors.white),
                    ),
                    title: Text(
                      n.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2C6B2F),
                        fontSize: 15,
                        decoration: n.isRead ? TextDecoration.none : TextDecoration.none,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          n.message,
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(n.createdAt),
                          style: const TextStyle(color: Colors.black45, fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: n.isRead
                        ? null
                        : TextButton(
                            onPressed: () => notifP.markAsRead(n.id),
                            child: const Text("Đã đọc"),
                          ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: notifP.items.length,
              ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    final day = d.day.toString().padLeft(2, "0");
    final month = d.month.toString().padLeft(2, "0");
    final hour = d.hour.toString().padLeft(2, "0");
    final minute = d.minute.toString().padLeft(2, "0");
    return "$hour:$minute $day/$month";
  }
}
