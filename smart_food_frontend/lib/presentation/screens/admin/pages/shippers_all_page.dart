import 'package:flutter/material.dart';

class ShippersAllPage extends StatelessWidget {
  const ShippersAllPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Shippers"),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _shipperCard("41", "Pham Minh A", "0905001122", "43A1-123.45", "Active"),
          _shipperCard("42", "Tran Van B", "0905223344", "43B1-678.90", "Active"),
          _shipperCard("43", "Le Thanh C", "0905334455", "43C1-345.67", "Blocked"),
        ],
      ),
    );
  }

  Widget _shipperCard(
    String id,
    String name,
    String phone,
    String plate,
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
          child: Icon(
            Icons.delivery_dining,
            color: color,
            size: 26,
          ),
        ),

        title: Text(
          name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text("Phone: $phone"),
            Text("Plate: $plate"),

            const SizedBox(height: 8),

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
