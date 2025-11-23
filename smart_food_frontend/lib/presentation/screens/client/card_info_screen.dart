import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/payment_model.dart';
import 'package:smart_food_frontend/providers/payment_provider.dart';

class CardInfoScreen extends StatefulWidget {
  final PaymentModel payment;

  const CardInfoScreen({
    super.key,
    required this.payment,
  });

  static const backgroundColor = Color(0xFFFFF6EC);
  static const primaryGreen = Color(0xFF5B7B56);

  @override
  State<CardInfoScreen> createState() => _CardInfoScreenState();
}

class _CardInfoScreenState extends State<CardInfoScreen> {
  bool deleting = false;

  Future<void> _confirmDelete() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text(
            "Bạn có chắc muốn xóa thẻ ${widget.payment.bankName} khỏi tài khoản của bạn?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePayment();
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePayment() async {
    setState(() => deleting = true);

    final provider = Provider.of<PaymentProvider>(context, listen: false);
    final success = await provider.deletePayment(widget.payment.id);

    setState(() => deleting = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã xóa ${widget.payment.bankName}")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xóa thất bại, vui lòng thử lại.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CardInfoScreen.backgroundColor,
      appBar: AppBar(
        backgroundColor: CardInfoScreen.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child:
              const Icon(Icons.arrow_back, color: CardInfoScreen.primaryGreen),
        ),
        title: Text(
          widget.payment.bankName,
          style: const TextStyle(
            color: CardInfoScreen.primaryGreen,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            tooltip: widget.payment.isDefault ? "Mặc định" : "Đặt làm mặc định",
            icon: Icon(
              Icons.check_circle,
              color: widget.payment.isDefault ? Colors.green : Colors.grey,
              size: 26,
            ),
            onPressed: widget.payment.isDefault || deleting
                ? null
                : () async {
                    final ok = await Provider.of<PaymentProvider>(
                      context,
                      listen: false,
                    ).setDefault(widget.payment.id);

                    if (!mounted) return;

                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Đã đặt làm tài khoản mặc định"),
                        ),
                      );
                      Navigator.pop(context); 
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Không thể đặt làm mặc định"),
                        ),
                      );
                    }
                  },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BANK HEADER
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.payment.bankLogo,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.payment.bankName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    ],
                  ),
                  const Divider(thickness: 1, color: Colors.black12),
                  const SizedBox(height: 20),

                  _fullRow("Số tài khoản", widget.payment.accountNumber),
                  const SizedBox(height: 16),

                  _fullRow("Chủ tài khoản", widget.payment.accountHolder),
                  const SizedBox(height: 16),

                  _fullRow("CMND / CCCD", widget.payment.idNumber),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: deleting ? null : _confirmDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: deleting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Xóa liên kết",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _fullRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
