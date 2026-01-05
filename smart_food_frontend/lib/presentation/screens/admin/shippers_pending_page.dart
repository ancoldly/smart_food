import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/providers/shipper_provider.dart';

class ShippersPendingPage extends StatefulWidget {
  const ShippersPendingPage({super.key});

  @override
  State<ShippersPendingPage> createState() => _ShippersPendingPageState();
}

class _ShippersPendingPageState extends State<ShippersPendingPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ShipperProvider>(context, listen: false)
          .loadAdminShippers(status: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShipperProvider>(context);
    final pending = provider.adminShippers;

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
          "Shipper Pending",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: provider.adminLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF5B7B56)),
              )
            : pending.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.hourglass_empty,
                            size: 72, color: Color(0xFF5B7B56)),
                        const SizedBox(height: 12),
                        const Text(
                          "Chưa có hồ sơ chờ duyệt.",
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFF5B3A1E)),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () => provider.loadAdminShippers(
                            status: 1,
                          ),
                          child: const Text("Làm mới"),
                        )
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: pending.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final s = pending[index];
                      return _pendingCard(context, s);
                    },
                  ),
      ),
    );
  }

  Widget _pendingCard(BuildContext context, Map<String, dynamic> shipper) {
    final provider = Provider.of<ShipperProvider>(context, listen: false);
    final fullName = shipper["full_name"] ?? "N/A";
    final phone = shipper["phone"] ?? "";
    final plate = shipper["license_plate"] ?? "";
    final id = shipper["id"] as int? ?? 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.orange.withOpacity(0.15),
              child: const Icon(Icons.pending_actions,
                  color: Colors.orange, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("Phone: $phone"),
                  Text("Plate: $plate"),
                  const SizedBox(height: 6),
                  Chip(
                    label: const Text("Pending"),
                    backgroundColor: Colors.orange.withOpacity(0.15),
                    labelStyle: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final ok = await provider.approveShipper(id);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? "Đã duyệt" : "Lỗi, thử lại"),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(80, 36),
                  ),
                  child: const Text("Duyệt"),
                ),
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: () async {
                    final ok = await provider.rejectShipper(id);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? "Đã từ chối" : "Lỗi, thử lại"),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(80, 36),
                  ),
                  child: const Text("Từ chối"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
