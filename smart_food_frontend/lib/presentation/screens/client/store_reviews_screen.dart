import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:smart_food_frontend/data/services/review_service.dart';

class StoreReviewsScreen extends StatefulWidget {
  final int storeId;
  final String storeName;
  const StoreReviewsScreen({
    super.key,
    required this.storeId,
    required this.storeName,
  });

  @override
  State<StoreReviewsScreen> createState() => _StoreReviewsScreenState();
}

class _StoreReviewsScreenState extends State<StoreReviewsScreen> {
  final DateFormat _df = DateFormat("dd/MM/yyyy HH:mm");
  bool _loading = true;
  List<Map<String, dynamic>> _reviews = [];
  Map<int, int> _counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  double _avg = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ReviewService.fetchByStore(widget.storeId);
      if (!mounted) return;
      _computeSummary(data);
      setState(() {
        _reviews = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _computeSummary(List<Map<String, dynamic>> reviews) {
    final counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in reviews) {
      final rating = (r["rating"] ?? 0).toInt();
      if (counts.containsKey(rating)) counts[rating] = counts[rating]! + 1;
    }
    final total = counts.values.fold<int>(0, (a, b) => a + b);
    final avg = total == 0
        ? 0.0
        : counts.entries.fold<double>(
              0,
              (sum, e) => sum + (e.key * e.value),
            ) /
            total;
    _counts = counts;
    _avg = avg.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF5B7B56)),
        ),
        title: const Text(
          "Nhận xét của mọi người",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFFF6EC),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Mọi người nhận xét",
              style: TextStyle(
                color: Color(0xFFE05A3E),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _summaryCard(),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_reviews.isEmpty)
              const Text(
                "Chưa có nhận xét",
                style: TextStyle(color: Colors.black54),
              )
            else
              ..._reviews.map(_reviewCard).toList(),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final count = _counts[star] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text("$star", style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      _stars(star, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F3EB),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (_counts.values.fold<int>(0, (a, b) => a + b)) > 0
                                ? count / (_counts.values.fold<int>(0, (a, b) => a + b))
                                : 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE76F51),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text("$count"),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _avg.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE76F51),
                ),
              ),
              const SizedBox(height: 4),
              _stars(_avg.round(), size: 16),
              Text(
                "${_counts.values.fold<int>(0, (a, b) => a + b)} đánh giá",
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(Map<String, dynamic> review) {
    final name = (review["user_name"] ?? "Khách hàng").toString();
    final comment = (review["comment"] ?? "").toString();
    final rating = (review["rating"] ?? 0);
    final created = review["created_at"]?.toString();
    final productName = (review["product_name"] ?? "").toString();
    final reply = (review["reply_comment"] ?? "").toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                child: Icon(Icons.person, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    if (created != null && created.isNotEmpty)
                      Text(
                        _formatDate(created),
                        style:
                            const TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                  ],
                ),
              ),
              _stars(rating),
            ],
          ),
          const SizedBox(height: 8),
          if (productName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                "Món: $productName",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF391713),
                ),
              ),
            ),
          Text(
            comment.isNotEmpty ? comment : "Chưa có nội dung đánh giá",
            style: const TextStyle(color: Colors.black87),
          ),
          if (reply.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3EB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.reply, size: 16, color: Color(0xFF1F7A52)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      reply,
                      style: const TextStyle(color: Color(0xFF1F7A52)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return "";
    return _df.format(dt);
  }

  Widget _stars(num rating, {double size = 16}) {
    final rounded = rating is int ? rating : rating.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rounded ? Icons.star : Icons.star_border,
          size: size,
          color: const Color(0xFFE05A3E),
        ),
      ),
    );
  }
}
