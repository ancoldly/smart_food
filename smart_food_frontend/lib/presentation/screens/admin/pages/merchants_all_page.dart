import 'package:flutter/material.dart';

class MerchantsAllPage extends StatelessWidget {
  const MerchantsAllPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Merchants"),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _merchantCard(
            "21",
            "Bún Bò Huế A",
            "Nguyễn Văn A",
            "0123456789",
            "Active",
          ),
          _merchantCard(
            "22",
            "Trà Sữa B",
            "Trần Thị B",
            "0987654321",
            "Active",
          ),
          _merchantCard(
            "23",
            "Cơm Gà C",
            "Lê Văn C",
            "0909009900",
            "Blocked",
          ),
        ],
      ),
    );
  }

  //────────────────────────────────────────────
  //              MERCHANT CARD UI
  //────────────────────────────────────────────
  Widget _merchantCard(
    String id,
    String store,
    String owner,
    String phone,
    String status,
  ) {
    final color = _statusColor(status);

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
          backgroundColor: color.withOpacity(0.15),
          child: const Icon(Icons.storefront, size: 28, color: Colors.blueGrey),
        ),

        title: Text(
          store,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Owner: $owner"),
            Text("Phone: $phone"),
            const SizedBox(height: 6),

            Chip(
              label: Text(status),
              backgroundColor: color.withOpacity(0.15),
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            )
          ],
        ),

        trailing: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () {},
            ),

            IconButton(
              icon: Icon(
                status == "Blocked" ? Icons.lock_open : Icons.block,
                color: status == "Blocked" ? Colors.green : Colors.red,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  //────────────────────────────────────────────
  //                   STATUS COLOR
  //────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status) {
      case "Active":
        return Colors.green;
      case "Blocked":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
