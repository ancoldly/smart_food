import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';

class MerchantsPendingPage extends StatefulWidget {
  const MerchantsPendingPage({super.key});

  @override
  State<MerchantsPendingPage> createState() => _MerchantsPendingPageState();
}

class _MerchantsPendingPageState extends State<MerchantsPendingPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<StoreProvider>(context, listen: false).loadStores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StoreProvider>(context);
    final pendingStores = provider.stores.where((e) => e.status == 1).toList();

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
          "Merchant Pending",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: provider.loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF5B7B56)),
              )

            // EMPTY LIST
            : pendingStores.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/no_pending.png",
                          width: 180,
                          height: 180,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Chưa có cửa hàng cần duyệt.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF5B3A1E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )

                // LIST VIEW
                : ListView.separated(
                    itemCount: pendingStores.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final s = pendingStores[index];
                      return _merchantItem(context, s);
                    },
                  ),
      ),
    );
  }

  //────────────────────────────────────────────
  //          MERCHANT ITEM (simple clean UI)
  //────────────────────────────────────────────
  Widget _merchantItem(BuildContext context, store) {
    final provider = Provider.of<StoreProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.orange.withOpacity(0.15),
            child: const Icon(Icons.store, color: Colors.orange, size: 26),
          ),

          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.storeName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text("Owner: ${store.managerName}"),
                Text("Phone: ${store.managerPhone}"),
                const SizedBox(height: 6),
                Chip(
                  label: const Text("Pending"),
                  backgroundColor: Colors.orange.withOpacity(0.12),
                  labelStyle: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Approve / Reject
          Column(
            children: [
              ElevatedButton(
                onPressed: () => _approve(context, provider, store.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(80, 36),
                ),
                child: const Text("Approve"),
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: () => _reject(context, provider, store.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(80, 36),
                ),
                child: const Text("Reject"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //────────────────────────────────────────────
  // APPROVE & REJECT
  //────────────────────────────────────────────
  void _approve(BuildContext context, StoreProvider provider, int id) async {
    final ok = await provider.approveStore(id);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(ok ? "Đã duyệt" : "Lỗi")));

    setState(() {}); // refresh UI
  }

  void _reject(BuildContext context, StoreProvider provider, int id) async {
    final ok = await provider.rejectStore(id);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(ok ? "Đã từ chối" : "Lỗi")));

    setState(() {}); // refresh UI
  }
}
