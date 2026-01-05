import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/providers/notification_provider.dart';
import 'package:smart_food_frontend/data/models/notification_model.dart';

class ClientNotificationsScreen extends StatefulWidget {
  const ClientNotificationsScreen({super.key});

  @override
  State<ClientNotificationsScreen> createState() => _ClientNotificationsScreenState();
}

class _ClientNotificationsScreenState extends State<ClientNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<NotificationProvider>().fetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final notifP = context.watch<NotificationProvider>();
    final items = notifP.items;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF5B7B56)),
        ),
        title: const Text(
          "Thông báo",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: notifP.loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text("Chưa có thông báo"))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final n = items[index];
                    return _NotificationTile(
                      model: n,
                      onTap: () => _markRead(n.id),
                    );
                  },
                ),
    );
  }

  Future<void> _markRead(int id) async {
    await context.read<NotificationProvider>().markAsRead(id);
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel model;
  final VoidCallback? onTap;

  const _NotificationTile({required this.model, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(
        model.isRead ? Icons.notifications_none : Icons.notifications_active,
        color: model.isRead ? Colors.grey : const Color(0xFFFF7043),
      ),
      title: Text(
        model.title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            model.message,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 2),
          Text(
            model.createdAt.toLocal().toString(),
            style: const TextStyle(color: Colors.black38, fontSize: 12),
          ),
        ],
      ),
      trailing: !model.isRead
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE0B2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Mới",
                style: TextStyle(
                  color: Color(0xFFFF7043),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            )
          : null,
    );
  }
}
