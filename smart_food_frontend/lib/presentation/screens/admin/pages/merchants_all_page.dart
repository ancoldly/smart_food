import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';

class MerchantsAllPage extends StatefulWidget {
  const MerchantsAllPage({super.key});

  @override
  State<MerchantsAllPage> createState() => _MerchantsAllPageState();
}

class _MerchantsAllPageState extends State<MerchantsAllPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await Provider.of<StoreProvider>(context, listen: false)
          .loadStoresAdmin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StoreProvider>(context);
    final stores = provider.stores;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Merchants",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : stores.isEmpty
              ? const Center(child: Text("No stores found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: stores.length,
                  itemBuilder: (_, i) {
                    return _merchantCard(stores[i]);
                  },
                ),
    );
  }

  //────────────────────────────────────────────
  //              MERCHANT CARD UI
  //────────────────────────────────────────────
  Widget _merchantCard(StoreModel store) {
    final statusText = _statusText(store.status);
    final statusColor = _statusColor(statusText);

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
          backgroundColor: statusColor.withOpacity(0.15),
          child: const Icon(Icons.storefront, size: 28, color: Colors.blueGrey),
        ),
        title: Text(
          store.storeName ?? "No name",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Owner: ${store.managerName}"),
            Text("Phone: ${store.managerPhone}"),
            const SizedBox(height: 6),
            Chip(
              label: Text(statusText),
              backgroundColor: statusColor.withOpacity(0.15),
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: statusColor,
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
          ],
        ),
      ),
    );
  }

  //────────────────────────────────────────────
  //              STATUS HANDLER
  //────────────────────────────────────────────
  String _statusText(int status) {
    switch (status) {
      case 1:
        return "Pending";
      case 2:
        return "Approved";
      case 3:
        return "Rejected";
      case 4:
        return "Active";
      default:
        return "Unknown";
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Active":
        return Colors.green;
      case "Approved":
        return Colors.blue;
      case "Pending":
        return Colors.orange;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
