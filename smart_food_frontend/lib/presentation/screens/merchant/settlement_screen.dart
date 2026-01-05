import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/payment_model.dart';
import 'package:smart_food_frontend/providers/earnings_provider.dart';
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
      context.read<PaymentProvider>().loadPayments();
      context.read<EarningsProvider>().fetchMerchant();
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentP = context.watch<PaymentProvider>();
    final earnings = context.watch<EarningsProvider>();
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
          "Thanh toán & Đối soát",
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
            const SizedBox(height: 8),
            if (defaultAcc != null)
              _bankBox(context, defaultAcc)
            else
              _emptyBank(context),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.merchantTopup);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C6B2F),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Nạp tiền",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.merchantWithdraw);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2C6B2F)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "Rút tiền",
                      style: TextStyle(color: Color(0xFF2C6B2F), fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.payment);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C6B2F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                "Thêm tài khoản",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle("Lịch sử giao dịch"),
            ..._historyList(context, earnings),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(BuildContext context) {
    final earnings = context.watch<EarningsProvider>();
    final loading = earnings.loadingMerchant;
    final total = earnings.merchantTotal;
    final count = earnings.merchantOrderCount;
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
            "Tổng kết gần nhất",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF391713),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _summaryTile(
                  "Doanh thu hoàn thành",
                  loading ? "..." : "${total.toStringAsFixed(0)}đ",
                  icon: Icons.payments,
                  color: const Color(0xFF2C6B2F)),
              const SizedBox(width: 10),
              _summaryTile(
                  "Số đơn hoàn thành",
                  loading ? "..." : "$count đơn",
                  icon: Icons.receipt_long,
                  color: const Color(0xFF9A1B1D)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _summaryTile("Đang xử lý", "0đ",
                  icon: Icons.hourglass_bottom, color: const Color(0xFF5B7B56)),
              const SizedBox(width: 10),
              _summaryTile("Khác", "0đ",
                  icon: Icons.more_horiz, color: const Color(0xFF9A6B00)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(String title, String value,
      {IconData? icon, Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon ?? Icons.star, size: 18, color: color ?? Colors.brown),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF391713),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2C6B2F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF391713),
      ),
    );
  }

  Widget _bankBox(BuildContext context, PaymentModel payment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E0D7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance, size: 32, color: Color(0xFF2C6B2F)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.bankName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  payment.accountNumber,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.payment);
            },
            child: const Text("Chỉnh sửa"),
          ),
        ],
      ),
    );
  }

  Widget _emptyBank(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E0D7)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF9A6B00)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Chưa có tài khoản nhận tiền, hãy thêm ngay.",
              style: TextStyle(color: Color(0xFF391713)),
            ),
          ),
        ],
      ),
    );
  }
  List<Widget> _historyList(BuildContext context, EarningsProvider earnings) {
    if (earnings.merchantTransactions.isEmpty) {
      return [const Text("Chưa có giao dịch", style: TextStyle(color: Colors.black54))];
    }
    return earnings.merchantTransactions.map((tx) {
      final amount = (tx["amount"] as num?)?.toDouble() ?? 0;
      final note = tx["note"]?.toString() ?? "";
      final created = tx["created_at"]?.toString() ?? "";
      final isPositive = amount >= 0;
      final money = "${isPositive ? '+' : '-'}${amount.abs().toStringAsFixed(0)}đ";
      final title = note.isNotEmpty ? note : (isPositive ? "Nhận tiền" : "Trả tiền");
      return _historyItem(created, money, title, isPositive: isPositive);
    }).toList();
  }

  Widget _historyItem(String date, String amount, String status, {bool isPositive = true}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isPositive ? Icons.call_received : Icons.call_made,
        color: isPositive ? const Color(0xFF2C6B2F) : const Color(0xFFE55C52),
      ),
      title: Text(
        amount,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(status),
      trailing: Text(
        date,
        style: const TextStyle(color: Colors.black54),
      ),
    );
  }

}
