import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_food_frontend/data/models/voucher_model.dart';

class VoucherDetailScreen extends StatelessWidget {
  final VoucherModel voucher;
  VoucherDetailScreen({super.key, required this.voucher});

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
    final maxText = isPercent && voucher.maxDiscountAmount != null
        ? "Tối đa: ${_formatMoney(voucher.maxDiscountAmount!)}đ"
        : "-";
    final time =
        "${voucher.startAt != null ? _df.format(voucher.startAt!) : '-'}  -  ${voucher.endAt != null ? _df.format(voucher.endAt!) : '-'}";

    return Scaffold(
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
      backgroundColor: const Color(0xFFFFF6EC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEBAE5B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: isPercent
                          ? const Color(0xFFE76E27)
                          : const Color(0xFF237B4B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.confirmation_num,
                          color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          voucher.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          voucher.description ?? "Không có mô tả",
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              _row("Mã voucher", voucher.code),
              _row("Loại giảm", isPercent ? "Giảm %" : "Giảm tiền"),
              _row("Giá trị giảm", discountText),
              _row("Giảm tối đa", maxText),
              _row("Đơn tối thiểu", "${_formatMoney(voucher.minOrderAmount)}đ"),
              _row("Thời gian áp dụng", time),
              _row("Tổng lượt dùng",
                  voucher.usageLimitTotal?.toString() ?? "Không giới hạn"),
              _row("Lượt/Người", voucher.usageLimitPerUser.toString()),
              _row("Đã dùng", voucher.usedCount.toString()),
              _row("Trạng thái", voucher.isActive ? "Đang hoạt động" : "Đã tắt"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
