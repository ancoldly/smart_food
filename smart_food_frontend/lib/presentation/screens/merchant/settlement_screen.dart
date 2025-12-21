import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/payment_model.dart';
import 'package:smart_food_frontend/providers/payment_provider.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';

class SettlementScreen extends StatefulWidget {
  const SettlementScreen({super.key});

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<PaymentProvider>(context, listen: false).loadPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentP = Provider.of<PaymentProvider>(context);
    final payments = paymentP.payments;
    final defaultAcc = payments.isEmpty
        ? null
        : (payments.firstWhere(
            (e) => e.isDefault,
            orElse: () => payments.first,
          ));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Thanh toán & đối soát",
          style: TextStyle(
            color: Color(0xFF391713),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryCard(context),
            const SizedBox(height: 16),
            _sectionTitle("Tài khoản nhận tiền"),
            if (defaultAcc != null)
              _bankBox(context, defaultAcc)
            else
              _emptyBank(context),
            const SizedBox(height: 16),
            _sectionTitle("Phương thức thanh toán"),
            _accountList(payments),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.payment),
                icon: const Icon(Icons.settings),
                label: const Text("Quản lý phương thức thanh toán"),
              ),
            ),
            const SizedBox(height: 16),
            _sectionTitle("Lịch sử chuyển khoản"),
            _historyItem("12/12/2025", "5.000.000đ", "Đã chuyển"),
            _historyItem("05/12/2025", "3.200.000đ", "Đã chuyển"),
            _historyItem("28/11/2025", "4.150.000đ", "Đã chuyển"),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          const Text(
            "Tổng kết kỳ gần nhất",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF391713),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _summaryTile("Doanh thu dự kiến", "8.350.000đ",
                  icon: Icons.payments, color: const Color(0xFF2C6B2F)),
              const SizedBox(width: 10),
              _summaryTile("Phí nền tảng", "350.000đ",
                  icon: Icons.receipt_long, color: const Color(0xFF9A1B1D)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _summaryTile("Số dư khả dụng", "8.000.000đ",
                    icon: Icons.account_balance_wallet,
                    color: const Color(0xFF391713)),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F7A52),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pushNamed(context, "/withdraw"),
                child: const Text(
                  "Yêu cầu rút",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _summaryTile(String title, String value,
      {required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bankBox(BuildContext context, PaymentModel acc) {
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
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_balance, color: Color(0xFF1565C0)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ngân hàng: ${acc.bankName}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF391713),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Số tài khoản: ${acc.accountNumber}",
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  "Chủ TK: ${acc.accountHolder}",
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.payment),
            child: const Text("Cập nhật"),
          )
        ],
      ),
    );
  }

  Widget _emptyBank(BuildContext context) {
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
      child: Row(
        children: [
          const Icon(Icons.account_balance, color: Colors.grey),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Chưa có tài khoản nhận tiền. Thêm phương thức thanh toán trước.",
              style: TextStyle(color: Colors.black87),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.payment),
            child: const Text("Thêm"),
          )
        ],
      ),
    );
  }

  Widget _accountList(List<PaymentModel> payments) {
    if (payments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          "Chưa có phương thức thanh toán.",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }
    return Column(
      children: payments
          .map(
            (p) => Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2E5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      p.isDefault ? "Mặc định" : "Phụ",
                      style: const TextStyle(
                          color: Color(0xFF9A1B1D),
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.bankName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF391713)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p.accountNumber,
                          style: const TextStyle(color: Colors.black87),
                        ),
                        Text(
                          p.accountHolder,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _historyItem(String date, String amount, String status) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2E5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              date,
              style: const TextStyle(
                color: Color(0xFF9A1B1D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              amount,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF391713),
              ),
            ),
          ),
          Text(
            status,
            style:
                const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: Color(0xFF391713),
      ),
    );
  }
}
