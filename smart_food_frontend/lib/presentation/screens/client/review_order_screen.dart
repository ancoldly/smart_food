import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/order_model.dart';
import 'package:smart_food_frontend/providers/review_provider.dart';

class ReviewOrderScreen extends StatefulWidget {
  final OrderModel order;
  const ReviewOrderScreen({super.key, required this.order});

  @override
  State<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends State<ReviewOrderScreen> {
  int storeRating = 5;
  String storeComment = "";
  late List<_ProductReview> productReviews;

  @override
  void initState() {
    super.initState();
    productReviews = widget.order.items
        .map((i) => _ProductReview(
              productId: i.productId,
              name: i.name,
              rating: 5,
              comment: "",
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewProvider>();
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
          "Đánh giá đơn hàng",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle("Đánh giá cửa hàng"),
          _ratingRow(storeRating, (v) => setState(() => storeRating = v)),
          TextField(
            decoration: const InputDecoration(
              labelText: "Nhận xét",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (v) => storeComment = v,
          ),
          const SizedBox(height: 16),
          _sectionTitle("Đánh giá món"),
          ...productReviews.map((p) => _productCard(p)).toList(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.loading ? null : _submit,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), backgroundColor: const Color(0xFF5B7B56)),
            child: provider.loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Gửi đánh giá", style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _productCard(_ProductReview p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          _ratingRow(p.rating, (v) => setState(() => p.rating = v)),
          const SizedBox(height: 6),
          TextField(
            decoration: const InputDecoration(
              labelText: "Nhận xét món",
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: (v) => p.comment = v,
          ),
        ],
      ),
    );
  }

  Widget _ratingRow(int value, ValueChanged<int> onChanged) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < value;
        return IconButton(
          icon: Icon(
            filled ? Icons.star : Icons.star_border,
            color: const Color(0xFFE67E22),
          ),
          onPressed: () => onChanged(i + 1),
        );
      }),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
    );
  }

  Future<void> _submit() async {
    final provider = context.read<ReviewProvider>();
    final payload = productReviews
        .where((p) => p.productId != 0)
        .map((p) => {
              "product_id": p.productId,
              "rating": p.rating,
              "comment": p.comment,
            })
        .toList();

    final ok = await provider.submit(
      orderId: widget.order.id,
      storeRating: storeRating,
      storeComment: storeComment,
      productReviews: payload,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gửi đánh giá thất bại")),
      );
    }
  }
}

class _ProductReview {
  final int productId;
  final String name;
  int rating;
  String comment;
  _ProductReview({
    required this.productId,
    required this.name,
    required this.rating,
    required this.comment,
  });
}
