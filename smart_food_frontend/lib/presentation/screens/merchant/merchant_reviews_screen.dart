import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/providers/merchant_review_provider.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';

class MerchantReviewsScreen extends StatefulWidget {
  const MerchantReviewsScreen({super.key});

  @override
  State<MerchantReviewsScreen> createState() => _MerchantReviewsScreenState();
}

class _MerchantReviewsScreenState extends State<MerchantReviewsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MerchantReviewProvider>().fetch());
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<StoreProvider>().myStore;
    final provider = context.watch<MerchantReviewProvider>();
    final df = DateFormat("dd/MM/yyyy HH:mm");

    final summary = provider.summary;
    final avg = (summary["avg"] ?? 0).toDouble();
    final total = summary["total"] ?? 0;
    final counts = summary["counts"] as Map? ?? {};

    return Scaffold(
       appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Đánh giá và phản hồi",
          style: TextStyle(
            color: Color(0xFF391713),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF9F1E6),
      body: RefreshIndicator(
        onRefresh: () => provider.fetch(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (store != null)
              Text(store.storeName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 12),
            _summaryCard(avg, total, counts),
            const SizedBox(height: 16),
            const Text("Phản hồi từ khách", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 10),
            if (provider.loading)
              const Center(child: CircularProgressIndicator())
            else if (provider.items.isEmpty)
              const Text("Chưa có đánh giá", style: TextStyle(color: Colors.black54))
            else
              ...provider.items.map((r) {
                final created = r["created_at"]?.toString();
                final time = created != null ? df.format(DateTime.tryParse(created) ?? DateTime.now()) : "";
                final reply = r["reply_comment"]?.toString() ?? "";
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(child: Icon(Icons.person)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r["user_name"]?.toString() ?? "Khách hàng",
                                    style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text(time, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                              ],
                            ),
                          ),
                          _stars((r["rating"] ?? 0).toInt()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if ((r["product_name"] ?? "").toString().isNotEmpty)
                        Text("Món: ${r["product_name"]}", style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(r["comment"]?.toString() ?? ""),
                      const SizedBox(height: 6),
                      if (reply.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F3EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.reply, size: 18, color: Color(0xFF1F7A52)),
                              const SizedBox(width: 6),
                              Expanded(child: Text(reply)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _showReplyDialog(r["id"], reply),
                          icon: const Icon(Icons.reply, size: 18),
                          label: Text(reply.isEmpty ? "Phản hồi" : "Sửa phản hồi"),
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(double avg, int total, Map counts) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(5, (i) {
                final star = 5 - i;
                final count = counts["$star"] ?? counts[star] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text("$star"),
                      const SizedBox(width: 4),
                      _stars(star),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F3EB),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: total > 0 ? count / (total.toDouble()) : 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE76F51),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text("$count"),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Text(avg.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFFE76F51))),
              const SizedBox(height: 4),
              _stars(avg.round()),
              Text("$total đánh giá", style: const TextStyle(color: Colors.black54)),
            ],
          )
        ],
      ),
    );
  }

  Widget _stars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return Icon(filled ? Icons.star : Icons.star_border, size: 16, color: const Color(0xFFE76F51));
      }),
    );
  }

  Future<void> _showReplyDialog(int reviewId, String current) async {
    final controller = TextEditingController(text: current);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Phản hồi đánh giá"),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Nhập phản hồi"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Gửi")),
        ],
      ),
    );
    if (ok != true) return;
    // ignore: use_build_context_synchronously
    final provider = context.read<MerchantReviewProvider>();
    final success = await provider.reply(reviewId, controller.text.trim());
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gửi phản hồi thất bại")));
    }
  }
}
