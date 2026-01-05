import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/providers/earnings_provider.dart';
import 'package:smart_food_frontend/providers/payment_provider.dart';

class ShipperWithdrawScreen extends StatefulWidget {
  const ShipperWithdrawScreen({super.key});

  @override
  State<ShipperWithdrawScreen> createState() => _ShipperWithdrawScreenState();
}

class _ShipperWithdrawScreenState extends State<ShipperWithdrawScreen> {
  final TextEditingController amountCtrl = TextEditingController(text: "50000");

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PaymentProvider>().loadPayments();
      context.read<EarningsProvider>().fetchShipper();
    });
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF9F1E6);
    const green = Color(0xFF1F7A52);
    final earnings = context.watch<EarningsProvider>();

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
          "Rút tiền",
          style: TextStyle(color: Color(0xFF1F7A52), fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _balance(earnings.shipperTotal),
            const SizedBox(height: 12),
            _inputCard(),
            const SizedBox(height: 20),
            _submitRow(green, earnings),
          ],
        ),
      ),
    );
  }

  Widget _balance(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Số dư khả dụng", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            "${total.toStringAsFixed(0)}đ",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F7A52)),
          ),
        ],
      ),
    );
  }

  Widget _inputCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Nhập số tiền rút", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.money, color: Color(0xFF1F7A52)),
              border: InputBorder.none,
              hintText: "Nhập số tiền muốn rút",
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitRow(Color green, EarningsProvider earnings) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Phí giao dịch", style: TextStyle(color: Colors.black54)),
              SizedBox(height: 4),
              Text(
                "Miễn phí 5 giao dịch/tháng",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              if (amount <= 0) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Nhập số tiền hợp lệ")));
                return;
              }
              if (amount > earnings.shipperTotal) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Số dư không đủ")));
                return;
              }

              final ok = await earnings.withdrawShipper(amount);
              if (ok) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Đã rút ${amount.toStringAsFixed(0)}đ thành công")),
                  );
                  Navigator.pop(context);
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("Rút tiền thất bại")));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Rút tiền",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          )
        ],
      ),
    );
  }
}
