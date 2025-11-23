import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders Management"),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _orderCard("1001", "Nguyen Van A", "Bún Bò Huế A", "125,000đ", "Completed"),
          _orderCard("1002", "Tran Thi B", "Trà Sữa B", "65,000đ", "Preparing"),
          _orderCard("1003", "Le Van C", "Cơm Gà C", "45,000đ", "Pending"),
          _orderCard("1004", "Pham Minh D", "Pizza Deli", "150,000đ", "Canceled"),
        ],
      ),
    );
  }

  //────────────────────────────────────────────────────────────
  //                    ORDER CARD (LIST TILE)
  //────────────────────────────────────────────────────────────
  Widget _orderCard(
    String id,
    String user,
    String merchant,
    String total,
    String status,
  ) {
    final color = _statusColor(status);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        // ICON ORDER
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.15),
          child: const Icon(Icons.receipt_long, size: 26, color: Colors.black87),
        ),

        // TITLE + INFO
        title: Text(
          "Order #$id",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Customer: $user"),
            Text("Merchant: $merchant"),
            Text("Total: $total"),

            const SizedBox(height: 6),
            Chip(
              label: Text(status),
              backgroundColor: color.withOpacity(0.15),
              labelStyle: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        // ACTION BUTTONS
        trailing: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () {
                // xem chi tiết đơn hàng
              },
            ),
            IconButton(
              icon: const Icon(Icons.print, color: Colors.black87),
              onPressed: () {
                // in hóa đơn
              },
            ),
          ],
        ),
      ),
    );
  }

  //────────────────────────────────────────────────────────────
  //                   STATUS COLOR
  //────────────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "Preparing":
        return Colors.orange;
      case "Pending":
        return Colors.blue;
      case "Canceled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
