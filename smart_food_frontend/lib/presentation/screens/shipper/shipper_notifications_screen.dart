import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/providers/notification_provider.dart';
import 'package:smart_food_frontend/data/models/notification_model.dart';
import 'package:smart_food_frontend/providers/shipper_order_provider.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';

class ShipperNotificationsScreen extends StatefulWidget {
  const ShipperNotificationsScreen({super.key});

  @override
  State<ShipperNotificationsScreen> createState() => _ShipperNotificationsScreenState();
}

class _ShipperNotificationsScreenState extends State<ShipperNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final notifP = context.read<NotificationProvider>();
      await notifP.fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifP = context.watch<NotificationProvider>();
    const bg = Color(0xFFF9F1E6);
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
          "Thông báo",
          style: TextStyle(
            color: Color(0xFF1F7A52),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF9F1E6),
      body: RefreshIndicator(
        onRefresh: () => notifP.fetchNotifications(),
        child: notifP.loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemBuilder: (_, i) => _item(notifP.items[i]),
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: notifP.items.length,
              ),
      ),
    );
  }

  Widget _item(NotificationModel n) {
    return InkWell(
      onTap: () {
        context.read<NotificationProvider>().markAsRead(n.id);
        if (n.orderId != null) {
          final op = context.read<ShipperOrderProvider>();
          final all = [...op.assigned, ...op.available];
          final found = all.where((o) => o.id == n.orderId).toList();
          if (found.isNotEmpty) {
            Navigator.pushNamed(context, AppRoutes.orderDetail, arguments: found.first);
          }
        }
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              n.isRead ? Icons.notifications_none : Icons.notifications_active,
              color: n.isRead ? Colors.grey : const Color(0xFFE76F51),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.message,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
            if (!n.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFFE76F51), shape: BoxShape.circle),
              )
          ],
        ),
      ),
    );
  }
}
