import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/models/order_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

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
          "Chi tiết đơn hàng",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF9F1E6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard(),
            const SizedBox(height: 12),
            _addressCard(),
            const SizedBox(height: 12),
            _itemsCard(),
            const SizedBox(height: 12),
            _paymentCard(),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _box(),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              _absoluteImageUrl(order.storeAvatar).isNotEmpty
                  ? _absoluteImageUrl(order.storeAvatar)
                  : "https://via.placeholder.com/80x80.png?text=Store",
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 70,
                height: 70,
                color: Colors.grey.shade200,
                child: const Icon(Icons.store, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.storeName.isNotEmpty ? order.storeName : "Cửa hàng #${order.storeId}",
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  order.storeAddress.isNotEmpty ? order.storeAddress : "Không có địa chỉ",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 6),
                _statusChip(order.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Giao đến",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            order.receiverName.isNotEmpty ? order.receiverName : "Khách hàng",
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          if (order.receiverPhone.isNotEmpty)
            Text(order.receiverPhone, style: const TextStyle(color: Colors.black87)),
          if (order.addressLine.isNotEmpty)
            Text(order.addressLine, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _itemsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Món ăn",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...order.items.map(
            (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _absoluteImageUrl(i.productImage).isNotEmpty
                          ? _absoluteImageUrl(i.productImage)
                          : "https://via.placeholder.com/60x60.png?text=Item",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          i.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "x${i.quantity}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _currency(i.lineTotal),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _box(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Mã đơn #${order.id}", style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                _formatDate(order.createdAt),
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _row("Tạm tính", order.subtotal),
          _row("Phí vận chuyển", order.shippingFee),
          _row("Giảm giá", -order.discount),
          const Divider(),
          _row("Tổng cộng", order.total, bold: true),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Thanh toán: ${order.paymentMethod == "cash" ? "Tiền mặt" : "Thẻ"}"),
              _statusChip(order.status),
            ],
          )
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    final day = d.day.toString().padLeft(2, "0");
    final month = d.month.toString().padLeft(2, "0");
    final hour = d.hour.toString().padLeft(2, "0");
    final minute = d.minute.toString().padLeft(2, "0");
    return "$hour:$minute $day/$month";
  }

  Widget _row(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black54,
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          Text(
            _currency(value),
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg = Colors.grey.shade200;
    Color fg = Colors.black87;
    String label = status;
    switch (status) {
      case "pending":
        label = "Chờ xác nhận";
        bg = const Color(0xFFFFF2CC);
        fg = const Color(0xFF9A6B00);
        break;
      case "preparing":
        label = "Đang chuẩn bị";
        bg = const Color(0xFFE1F5FE);
        fg = const Color(0xFF0277BD);
        break;
      case "delivering":
        label = "Đang giao";
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
      case "completed":
        label = "Hoàn thành";
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
      case "cancelled":
        label = "Đã hủy";
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 4),
        )
      ],
      border: Border.all(color: const Color(0xFFE8E0D7)),
    );
  }

  String _absoluteImageUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    if (url.startsWith("http")) return url;
    final normalized = url.startsWith("/") ? url : "/$url";
    return "http://10.0.2.2:8000$normalized";
  }

  String _currency(double value) => "${value.toStringAsFixed(0)}đ";
}
