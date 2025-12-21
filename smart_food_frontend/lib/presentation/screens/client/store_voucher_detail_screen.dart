import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_food_frontend/data/models/store_voucher_model.dart';

class StoreVoucherDetailScreen extends StatelessWidget {
  final StoreVoucherModel voucher;
  StoreVoucherDetailScreen({super.key, required this.voucher});

  final DateFormat _df = DateFormat("dd/MM/yyyy");

  String _formatMoney(double v) {
    return v
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.");
  }

  @override
  Widget build(BuildContext context) {
    final isPercent = voucher.discountType == "percent";
    final discountText = isPercent
        ? "${voucher.discountValue.toStringAsFixed(0)}%"
        : "${_formatMoney(voucher.discountValue)}đ";
    final maxText = isPercent && voucher.maxDiscountValue != null
        ? "Tối đa: ${_formatMoney(voucher.maxDiscountValue!)}đ"
        : "-";
    final time =
        "${voucher.startDate ?? '-'}  -  ${voucher.endDate ?? '-'}";

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        title: const Text("Chi tiết voucher"),
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF5B7B56)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF5B7B56),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card(discountText, maxText, time),
            const SizedBox(height: 16),
            const Text(
              "Điều kiện",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF391713),
              ),
            ),
            const SizedBox(height: 8),
            _line("Mô tả", voucher.description.isNotEmpty ? voucher.description : "Không có mô tả"),
            _line("Đơn tối thiểu",
                voucher.minOrderValue > 0 ? "${_formatMoney(voucher.minOrderValue)}đ" : "Không yêu cầu"),
            _line("Giảm tối đa", maxText != "-" ? maxText : "Không giới hạn"),
            _line("Giới hạn lượt dùng",
                voucher.usageLimit != null ? voucher.usageLimit.toString() : "Không giới hạn"),
            _line("Đang hoạt động", voucher.isActive ? "Có" : "Không"),
          ],
        ),
      ),
    );
  }

  Widget _card(String discount, String maxText, String time) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDE0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.card_giftcard,
                    color: Color(0xFF9A1B1D), size: 28),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Giảm $discount",
                    style: const TextStyle(
                      color: Color(0xFF9A1B1D),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    maxText != "-" ? maxText : "Không giới hạn",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Hiệu lực: $time",
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF391713),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
