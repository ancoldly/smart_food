import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/payment_model.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/earnings_provider.dart';
import 'package:smart_food_frontend/providers/payment_provider.dart';

class ShipperWalletScreen extends StatefulWidget {
  const ShipperWalletScreen({super.key});

  @override
  State<ShipperWalletScreen> createState() => _ShipperWalletScreenState();
}

class _ShipperWalletScreenState extends State<ShipperWalletScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PaymentProvider>().loadPayments();
      context.read<EarningsProvider>().fetchShipper();
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF9F1E6);
    const green = Color(0xFF1F7A52);

    final paymentP = context.watch<PaymentProvider>();
    final earnings = context.watch<EarningsProvider>();
    final payments = paymentP.payments;
    final defaultAcc = payments.isEmpty
        ? null
        : payments.firstWhere((e) => e.isDefault, orElse: () => payments.first);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F7A52)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Ví & giao dịch",
          style: TextStyle(
            color: Color(0xFF1F7A52),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: paymentP.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _balanceCard(earnings),
                  const SizedBox(height: 16),
                  _defaultAccountSection(defaultAcc),
                  const SizedBox(height: 16),
                  _paymentListSection(payments),
                  const SizedBox(height: 16),
                  _historySection(earnings),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.shipperTopup),
        backgroundColor: green,
        label: const Text(
          "Nạp tiền nhanh",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _balanceCard(EarningsProvider earnings) {
    final loading = earnings.loadingShipper;
    final total = earnings.shipperTotal;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Tài khoản chính",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loading ? "..." : "${total.toStringAsFixed(0)}đ",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F7A52),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _walletAction("Nạp tiền", Icons.account_balance_wallet, AppRoutes.shipperTopup),
              _walletAction("Rút tiền", Icons.payments, AppRoutes.shipperWithdraw),
            ],
          )
        ],
      ),
    );
  }

  Widget _walletAction(String label, IconData icon, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1F7A52),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultAccountSection(PaymentModel? defaultAcc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Ngân hàng đang liên kết",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
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
        const SizedBox(height: 8),
        if (defaultAcc != null)
          _bankTile(defaultAcc)
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8E0D7)),
            ),
            child: const Text(
              "Chưa có ngân hàng, hãy thêm ngay.",
              style: TextStyle(color: Colors.black87),
            ),
          ),
      ],
    );
  }

  Widget _bankTile(PaymentModel payment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E0D7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance, color: Color(0xFF1F7A52)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.bankName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  payment.accountNumber,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _paymentListSection(List<PaymentModel> payments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Phương thức thanh toán",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.payment);
              },
              child: const Text("Thêm"),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (payments.isEmpty)
          const Text("Chưa có phương thức", style: TextStyle(color: Colors.black54))
        else
          ...payments.map(_paymentTile),
      ],
    );
  }

  Widget _paymentTile(PaymentModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E0D7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card, color: Color(0xFF1F7A52)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.bankName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  p.accountNumber,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          if (p.isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1F7A52),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Mặc định",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _historySection(EarningsProvider earnings) {
    final combined = earnings.shipperTransactions.map((tx) {
      final amount = (tx["amount"] as num?)?.toDouble() ?? 0;
      final created = tx["created_at"] as DateTime?;
      final note = tx["note"]?.toString() ?? "";
      final isPositive = amount >= 0;
      return {
        "title": note.isNotEmpty ? note : (isPositive ? "Nhận tiền" : "Trả tiền"),
        "time": created?.toString() ?? "",
        "isPositive": isPositive,
        "displayAmount": amount,
      };
    }).toList();
    if (combined.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
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
          child: const Text(
            "Lịch sử giao dịch",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...combined.map((item) {
          final title = item["title"]?.toString() ?? "";
          final time = item["time"]?.toString() ?? "";
          final isPositive = item["isPositive"] == true;
          final displayAmount = (item["displayAmount"] as num?)?.toDouble() ?? 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
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
            child: Row(
              children: [
                Icon(
                  isPositive ? Icons.call_received : Icons.call_made,
                  color: isPositive ? const Color(0xFF1F7A52) : const Color(0xFFE55C52),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${isPositive ? '+' : '-'}${displayAmount.abs().toStringAsFixed(0)}đ",
                  style: TextStyle(
                    color: isPositive ? const Color(0xFF1F7A52) : const Color(0xFFE55C52),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
