import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/providers/shipper_provider.dart';

class ShippersAllPage extends StatefulWidget {
  const ShippersAllPage({super.key});

  @override
  State<ShippersAllPage> createState() => _ShippersAllPageState();
}

class _ShippersAllPageState extends State<ShippersAllPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ShipperProvider>(context, listen: false)
          .loadAdminShippers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ShipperProvider>(context);
    final list = provider.adminShippers;

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
          "Tất cả tài xế",
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
            : list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delivery_dining,
                            size: 72, color: Color(0xFF5B7B56)),
                        const SizedBox(height: 12),
                        const Text(
                          "Chưa có tài xế.",
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFF5B3A1E)),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () => provider.loadAdminShippers(),
                          child: const Text("Làm mới"),
                        )
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final s = list[index];
                      return _shipperCard(context, s);
                    },
                  ),
      ),
    );
  }

  Widget _shipperCard(BuildContext context, Map<String, dynamic> shipper) {
    final provider = Provider.of<ShipperProvider>(context, listen: false);
    final fullName = shipper["full_name"] ?? "N/A";
    final phone = shipper["phone"] ?? "";
    final plate = shipper["license_plate"] ?? "";
    final status = shipper["status"] as int? ?? 0;
    final id = shipper["id"] as int? ?? 0;

    final statusText = _statusText(status);
    final color = _statusColor(status);

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
              backgroundColor: color.withOpacity(0.15),
              child: Icon(Icons.delivery_dining, color: color, size: 26),
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
                    label: Text(statusText),
                    backgroundColor: color.withOpacity(0.15),
                    labelStyle: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.blue),
                  onPressed: () => provider.loadAdminShippers(),
                ),
                IconButton(
                  icon: Icon(
                    status == 4 ? Icons.lock_open : Icons.block,
                    color: status == 4 ? Colors.green : Colors.red,
                  ),
                  onPressed: () async {
                    final ok = await provider.banShipper(id, ban: status != 4);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? (status == 4
                                  ? "Đã gỡ khóa"
                                  : "Đã khóa tài xế")
                              : "Lỗi, thử lại",
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusText(int status) {
    switch (status) {
      case 1:
        return "Pending";
      case 2:
        return "Approved";
      case 3:
        return "Rejected";
      case 4:
        return "Banned";
      default:
        return "Unknown";
    }
  }

  Color _statusColor(int status) {
    switch (status) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}
