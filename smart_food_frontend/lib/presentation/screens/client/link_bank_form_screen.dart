import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/providers/payment_provider.dart';

class LinkBankFormScreen extends StatefulWidget {
  final String bankName;
  final String bankLogo;

  const LinkBankFormScreen({
    super.key,
    required this.bankName,
    required this.bankLogo,
  });

  static const Color backgroundColor = Color(0xFFFFF6EC);
  static const Color primaryGreen = Color(0xFF5B7B56);
  static const Color textBrown = Color(0xFF5B3A1E);

  @override
  State<LinkBankFormScreen> createState() => _LinkBankFormScreenState();
}

class _LinkBankFormScreenState extends State<LinkBankFormScreen> {
  final _accountNumber = TextEditingController();
  final _accountHolder = TextEditingController();
  final _idNumber = TextEditingController();
  bool _loading = false;

  Future<File> _assetToFile(String assetPath) async {
    final data = await rootBundle.load(assetPath);

    final tempDir = await getApplicationCacheDirectory();
    final file = File("${tempDir.path}/${assetPath.split('/').last}");

    await file.writeAsBytes(data.buffer.asUint8List());
    return file;
  }

  Future<void> _submit() async {
    if (_accountNumber.text.isEmpty ||
        _accountHolder.text.isEmpty ||
        _idNumber.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin.")),
      );
      return;
    }

    setState(() => _loading = true);

    File logoFile = await _assetToFile(widget.bankLogo);

    final fields = {
      "bank_name": widget.bankName,
      "account_number": _accountNumber.text.trim(),
      "account_holder": _accountHolder.text.trim(),
      "id_number": _idNumber.text.trim(),
      "is_default": "false"
    };

    // ignore: use_build_context_synchronously
    final success = await Provider.of<PaymentProvider>(
      context,
      listen: false,
    ).addPayment(
      fields: fields,
      bankLogo: logoFile,
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Liên kết ${widget.bankName} thành công!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Liên kết thất bại. Vui lòng thử lại.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LinkBankFormScreen.backgroundColor,
      appBar: AppBar(
        backgroundColor: LinkBankFormScreen.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back,
              color: LinkBankFormScreen.primaryGreen),
        ),
        title: Text(
          widget.bankName,
          style: const TextStyle(
            color: LinkBankFormScreen.primaryGreen,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Liên kết ${widget.bankName} bằng số tài khoản\nhoặc thẻ bạn nhé!",
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: LinkBankFormScreen.textBrown,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Thông tin tài khoản ngân hàng",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField("Số thẻ / tài khoản", _accountNumber),
                  const SizedBox(height: 10),
                  _buildTextField("Chủ thẻ / tài khoản", _accountHolder),
                  const SizedBox(height: 10),
                  _buildTextField("CMND / CCCD", _idNumber),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F4FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFD9F2)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF2F7EDB), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Các thông tin được nhập là thông tin bạn đã đăng ký tại Vietcombank khi mở thẻ / tài khoản.",
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, color: Colors.red, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Mọi thông tin của bạn đều được bảo mật theo tiêu chuẩn quốc tế PCI DSS.",
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: LinkBankFormScreen.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Tiếp tục",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 15, color: Colors.black38),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: LinkBankFormScreen.primaryGreen,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}
