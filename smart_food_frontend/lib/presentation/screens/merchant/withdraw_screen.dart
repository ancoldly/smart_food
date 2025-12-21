import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/payment_model.dart';
import 'package:smart_food_frontend/providers/payment_provider.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final List<int> _preset = [100000, 200000, 300000, 500000, 1000000, 1500000];
  int? _selectedAmount = 100000;
  final TextEditingController _customC = TextEditingController(text: "100000");
  static const int _min = 100000;
  static const int _max = 20000000;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<PaymentProvider>(context, listen: false).loadPayments();
    });
  }

  @override
  void dispose() {
    _customC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final payments = Provider.of<PaymentProvider>(context).payments;
    final bank = payments.isNotEmpty
        ? payments.firstWhere(
            (e) => e.isDefault,
            orElse: () => payments.first,
          )
        : null;

    final amount = _currentAmount();
    final fee = _calcFee(amount);
    final total = amount - fee;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Yêu cầu rút tiền",
          style: TextStyle(
            color: Color(0xFF2F5E3D),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _bankCard(bank),
            const SizedBox(height: 14),
            _amountSelector(),
            const SizedBox(height: 14),
            _feeCard(fee),
            const SizedBox(height: 14),
            _totalCard(total, amount, fee),
          ],
        ),
      ),
    );
  }

  Widget _bankCard(PaymentModel? bank) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8CC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance, color: Color(0xFF9A1B1D)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bank != null ? "Ngân hàng đang liên kết" : "Chưa liên kết",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF391713),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bank != null
                      ? "${bank.bankName} ${_maskAcc(bank.accountNumber)}"
                      : "Thêm phương thức thanh toán trước",
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                )
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, "/payment"),
            child: const Text("Thay đổi"),
          )
        ],
      ),
    );
  }

  Widget _amountSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            "Chọn số tiền",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF391713),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _preset
                .map((v) => _amountChip(
                      value: v,
                      selected: _selectedAmount == v,
                      onTap: () {
                        setState(() {
                          _selectedAmount = v;
                          _customC.text = v.toString();
                        });
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            "Nhập số tiền",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF391713),
            ),
          ),
          TextField(
            controller: _customC,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Color(0xFF9A1B1D),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            decoration: const InputDecoration(
              hintText: "Nhập số tiền",
              border: UnderlineInputBorder(),
            ),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              setState(() {
                _selectedAmount = parsed;
              });
            },
          ),
          const SizedBox(height: 6),
          Text(
            "Vui lòng nhập số tiền từ 100.000đ - 20.000.000đ",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          )
        ],
      ),
    );
  }

  Widget _amountChip(
      {required int value, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFE6E6) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF9A1B1D) : Colors.black26,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _fmtMoney(value),
          style: TextStyle(
            color: selected ? const Color(0xFF9A1B1D) : const Color(0xFF391713),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _feeCard(int fee) {
    return Container(
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
          const Icon(Icons.receipt_long, color: Color(0xFF9A1B1D)),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Phí giao dịch",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF391713),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "5 giao dịch miễn phí hằng ngày",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "1,200đ",
                style: TextStyle(
                  color: Colors.black38,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              Text(
                _fmtMoney(fee),
                style: const TextStyle(
                  color: Color(0xFF9A1B1D),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _totalCard(int total, int amount, int fee) {
    return Container(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tổng tiền rút",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF391713),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _fmtMoney(total),
                style: const TextStyle(
                  color: Color(0xFF9A1B1D),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F5E3D),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _submit(amount, fee, total),
            child: const Text(
              "Rút tiền",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtMoney(int v) {
    final s = v.toString();
    return s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.') + "đ";
  }

  String _maskAcc(String acc) {
    if (acc.length <= 4) return acc;
    return acc.substring(0, 4) + "******" + acc.substring(acc.length - 2);
  }

  int _currentAmount() {
    final val = _selectedAmount ?? int.tryParse(_customC.text) ?? 0;
    return val.clamp(_min, _max);
  }

  int _calcFee(int amount) {
    // Demo: 5 giao dịch miễn phí, đặt fee = 0
    return 0;
  }

  void _submit(int amount, int fee, int total) {
    if (_selectedAmount == null && int.tryParse(_customC.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập số tiền hợp lệ")),
      );
      return;
    }
    if (amount < _min || amount > _max) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Số tiền phải trong 100.000đ - 20.000.000đ")),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text("Đã gửi yêu cầu rút ${_fmtMoney(total)} (phí ${_fmtMoney(fee)})"),
      ),
    );
  }
}
