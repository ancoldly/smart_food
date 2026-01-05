import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/payment_model.dart';
import 'package:smart_food_frontend/providers/earnings_provider.dart';
import 'package:smart_food_frontend/providers/payment_provider.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';

class MerchantTopupScreen extends StatefulWidget {
  const MerchantTopupScreen({super.key});

  @override
  State<MerchantTopupScreen> createState() => _MerchantTopupScreenState();
}

class _MerchantTopupScreenState extends State<MerchantTopupScreen> {
  final TextEditingController amountCtrl = TextEditingController(text: "1000000");
  final List<int> preset = [500000, 1000000, 2000000, 3000000, 5000000, 10000000];
  int selected = 1000000;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PaymentProvider>().loadPayments();
      context.read<EarningsProvider>().fetchMerchant();
    });
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFF7EF);
    const green = Color(0xFF2C6B2F);

    final paymentP = context.watch<PaymentProvider>();
    final earnings = context.watch<EarningsProvider>();
    final payments = paymentP.payments;
    final bank = _pickBank(payments);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C6B2F)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Nạp tiền",
          style: TextStyle(color: Color(0xFF2C6B2F), fontWeight: FontWeight.w700),
        ),
      ),
      body: paymentP.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _bankCard(bank),
                  const SizedBox(height: 14),
                  _presetGrid(),
                  const SizedBox(height: 12),
                  _manualInput(),
                  const SizedBox(height: 16),
                  _submitRow(green, earnings),
                ],
              ),
            ),
    );
  }

  PaymentModel? _pickBank(List<PaymentModel> payments) {
    if (payments.isEmpty) return null;
    return payments.firstWhere((e) => e.isDefault, orElse: () => payments.first);
  }

  Widget _bankCard(PaymentModel? bank) {
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
      child: Row(
        children: [
          const Icon(Icons.account_balance, color: Color(0xFF2C6B2F), size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bank != null ? "Ngân hàng đang liên kết" : "Chưa liên kết ngân hàng",
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  bank != null ? "${bank.bankName} - ${bank.accountNumber}" : "Thêm tài khoản để nạp",
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.payment),
            child: const Text("Đổi"),
          )
        ],
      ),
    );
  }

  Widget _presetGrid() {
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
          const Text("Chọn số tiền", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: preset.map((p) {
              final active = p == selected;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selected = p;
                    amountCtrl.text = p.toString();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF2C6B2F) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: active ? const Color(0xFF2C6B2F) : const Color(0xFFE8E0D7)),
                  ),
                  child: Text(
                    "${p.toStringAsFixed(0)}đ",
                    style: TextStyle(
                      color: active ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _manualInput() {
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
          const Text("Nhập số tiền", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.currency_exchange, color: Color(0xFF2C6B2F)),
              border: InputBorder.none,
              hintText: "Nhập số tiền từ 100.000đ - 20.000.000đ",
            ),
            onChanged: (v) {
              final parsed = int.tryParse(v.replaceAll(".", "").replaceAll(",", "")) ?? 0;
              setState(() {
                selected = parsed;
              });
            },
          ),
          const SizedBox(height: 4),
          const Text(
            "Vui lòng nhập 100.000đ - 20.000.000đ",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          )
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tổng tiền nạp", style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 4),
              Text(
                "${selected.toStringAsFixed(0)}đ",
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              if (selected < 100000) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Số tiền tối thiểu 100.000đ")),
                );
                return;
              }
              final ok = await earnings.topupMerchant(selected.toDouble());
              if (ok) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Đã nạp ${selected.toStringAsFixed(0)}đ thành công")),
                  );
                  Navigator.pop(context);
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("Nạp tiền thất bại")));
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
              "Nạp tiền",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          )
        ],
      ),
    );
  }
}
