import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:smart_food_frontend/data/models/product_model.dart';
import 'package:smart_food_frontend/data/services/review_service.dart';
import 'package:smart_food_frontend/data/services/recommendation_service.dart';
import 'package:smart_food_frontend/presentation/widgets/cart/add_to_cart_bottom_sheet.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final DateFormat _df = DateFormat("dd/MM/yyyy HH:mm");
  List<Map<String, dynamic>> _reviews = [];
  bool _loadingReviews = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadReviews);
    RecommendationService.logEvent(
      productId: widget.product.id,
      storeId: widget.product.storeId,
      event: "product_view",
    );
  }

  Future<void> _loadReviews() async {
    setState(() => _loadingReviews = true);
    try {
      final data = await ReviewService.fetchByProduct(widget.product.id);
      if (!mounted) return;
      setState(() {
        _reviews = data;
        _loadingReviews = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingReviews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.product.imageUrl ?? widget.product.image ?? "";
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      body: SafeArea(
        child: Column(
          children: [
            _header(context, image),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadReviews,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoCard(context),
                      const SizedBox(height: 16),
                      _reviewsSection(),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, String image) {
    return Stack(
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: Image.network(
            image.isNotEmpty
                ? image
                : "https://www.svgrepo.com/show/422038/product.svg",
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.orange),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoCard(BuildContext context) {
    final product = widget.product;
    final soldCount = product.soldCount;
    final likes = _reviews.length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF391713),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description ?? "",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                ),
                const SizedBox(height: 6),
                if (product.discountPrice != null && product.discountPrice! > 0)
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${product.discountPrice!.toStringAsFixed(0)}đ ",
                          style: const TextStyle(
                            color: Color(0xFF9A1B1D),
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: "${product.price.toStringAsFixed(0)}đ",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    "${product.price.toStringAsFixed(0)}đ",
                    style: const TextStyle(
                      color: Color(0xFF9A1B1D),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  "${soldCount > 0 ? "$soldCount đã bán" : "Chưa có lượt bán"} | $likes lượt thích",
                  style: const TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () => showAddToCartBottomSheet(context, product),
            ),
          )
        ],
      ),
    );
  }

  Widget _reviewsSection() {
    final preview = _reviews.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              "Mọi người nhận xét",
              style: TextStyle(
                color: Color(0xFFE05A3E),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Spacer(),
          ],
        ),
        const SizedBox(height: 8),
        if (_loadingReviews)
          const Center(child: CircularProgressIndicator())
        else if (_reviews.isEmpty)
          const Text(
            "Chưa có nhận xét",
            style: TextStyle(color: Colors.black54),
          )
        else
          Column(
            children: preview.map((r) => _reviewCard(r)).toList(),
          ),
      ],
    );
  }

  Widget _reviewCard(Map<String, dynamic> review) {
    final comment = (review["comment"] ?? "").toString();
    final name = (review["user_name"] ?? "Khách hàng").toString();
    final rating = (review["rating"] ?? 0);
    final created = review["created_at"]?.toString();
    final productName = (review["product_name"] ?? "").toString();
    final reply = (review["reply_comment"] ?? "").toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.isNotEmpty ? comment : "Chưa có nội dung đánh giá",
            style: const TextStyle(
              color: Color(0xFF391713),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _stars(rating),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (productName.isNotEmpty)
                Flexible(
                  child: Text(
                    productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ),
              if (productName.isNotEmpty) const SizedBox(width: 6),
              if (created != null && created.isNotEmpty)
                Text(
                  _formatDate(created),
                  style: const TextStyle(color: Colors.black45, fontSize: 12),
                ),
            ],
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

  Widget _stars(num rating) {
    final rounded = rating is int ? rating : rating.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rounded ? Icons.star : Icons.star_border,
          size: 16,
          color: Colors.orange,
        ),
      ),
    );
  }
}
