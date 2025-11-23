import 'package:flutter/material.dart';

class ShippersPendingPage extends StatelessWidget {
  const ShippersPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shipper Pending Approval"),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _pendingCard(context, "41", "Pham Minh A", "0905001122", "43A1-123.45"),
          _pendingCard(context, "42", "Tran Van B", "0905223344", "43B1-678.90"),
        ],
      ),
    );
  }

  Widget _pendingCard(
    BuildContext context,
    String id,
    String name,
    String phone,
    String plate,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        leading: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.orange.withOpacity(0.15),
          child: const Icon(Icons.pending_actions, color: Colors.orange, size: 26),
        ),

        title: Text(
          name,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text("Phone: $phone"),
            Text("Plate: $plate"),

            const SizedBox(height: 8),
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

        trailing: Column(
          children: [
            ElevatedButton(
              onPressed: () => _showApproveSheet(context, name),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: const Text("Approve"),
            ),
            const SizedBox(height: 6),
            ElevatedButton(
              onPressed: () => _showRejectSheet(context, name),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: const Text("Reject"),
            ),
          ],
        ),
      ),
    );
  }

  //──────────────────────────────────────────
  //             BottomSheet Approve
  //──────────────────────────────────────────
  void _showApproveSheet(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Approve Shipper",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Text("Xác nhận duyệt shipper: $name ?"),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Hủy"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSnackbar(context, "Đã duyệt shipper $name");
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Duyệt"),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  //──────────────────────────────────────────
  //             BottomSheet Reject
  //──────────────────────────────────────────
  void _showRejectSheet(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Reject Shipper",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Text("Bạn có chắc muốn từ chối shipper: $name ?"),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Hủy"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSnackbar(context, "Đã từ chối shipper $name");
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Từ chối"),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // Snackbar tiện dụng
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
