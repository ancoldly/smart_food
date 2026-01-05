import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/shipper_provider.dart';

class ShipperRegisterScreen extends StatefulWidget {
  const ShipperRegisterScreen({super.key});

  @override
  State<ShipperRegisterScreen> createState() => _ShipperRegisterScreenState();
}

class _ShipperRegisterScreenState extends State<ShipperRegisterScreen> {
  final fullNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final vehicleCtrl = TextEditingController();
  final plateCtrl = TextEditingController();
  final idCtrl = TextEditingController();

  bool isSubmitting = false;

  @override
  void dispose() {
    fullNameCtrl.dispose();
    phoneCtrl.dispose();
    cityCtrl.dispose();
    addressCtrl.dispose();
    vehicleCtrl.dispose();
    plateCtrl.dispose();
    idCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final requiredFields = [
      fullNameCtrl.text.trim(),
      phoneCtrl.text.trim(),
      vehicleCtrl.text.trim(),
      plateCtrl.text.trim(),
      idCtrl.text.trim(),
    ];

    if (requiredFields.any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ thông tin bắt buộc"),
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);
    final provider = Provider.of<ShipperProvider>(context, listen: false);

    final ok = await provider.register({
      "full_name": fullNameCtrl.text.trim(),
      "phone": phoneCtrl.text.trim(),
      "city": cityCtrl.text.trim(),
      "address": addressCtrl.text.trim(),
      "vehicle_type": vehicleCtrl.text.trim(),
      "license_plate": plateCtrl.text.trim(),
      "id_number": idCtrl.text.trim(),
    });

    if (!mounted) return;
    setState(() => isSubmitting = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đăng ký tài xế thành công, vui lòng đợi duyệt"),
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.shipperPending);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thất bại, vui lòng thử lại")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFF6EC);
    const green = Color(0xFF1F7A52);
    const brown = Color(0xFF391713);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF5B7B56)),
        centerTitle: true,
        title: const Text(
          "Đăng ký tài xế",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heroCard(),
              const SizedBox(height: 20),
              const Text(
                "Lợi ích khi trở thành tài xế",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: brown,
                ),
              ),
              const SizedBox(height: 10),
              _bullet("Thu nhập linh hoạt, chủ động thời gian"),
              _bullet("Nhận chuyến gần bạn, tối ưu lộ trình"),
              _bullet("Hỗ trợ nhanh, thanh toán minh bạch"),
              const SizedBox(height: 20),
              const Text(
                "Yêu cầu cơ bản",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: brown,
                ),
              ),
              const SizedBox(height: 10),
              _bullet("CMND/CCCD, bằng lái, bảo hiểm xe"),
              _bullet("Smartphone kết nối internet"),
              _bullet("Tài khoản ngân hàng để nhận tiền"),
              const SizedBox(height: 26),
              const Text(
                "Thông tin đăng ký",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: brown,
                ),
              ),
              const SizedBox(height: 12),
              _inputField("Họ và tên *", "VD: Nguyễn Văn A", fullNameCtrl),
              const SizedBox(height: 14),
              _inputField("Số điện thoại *", "Nhập số điện thoại", phoneCtrl,
                  type: TextInputType.phone),
              const SizedBox(height: 14),
              _inputField("Thành phố", "Nhập thành phố", cityCtrl),
              const SizedBox(height: 14),
              _inputField(
                  "Địa chỉ cụ thể", "Nhập địa chỉ nhận hàng", addressCtrl),
              const SizedBox(height: 14),
              _inputField(
                  "Loại phương tiện *", "Xe máy, ô tô, ...", vehicleCtrl),
              const SizedBox(height: 14),
              _inputField("Biển số xe *", "Nhập biển số xe", plateCtrl),
              const SizedBox(height: 14),
              _inputField("Số CCCD/CMND *", "Nhập số CCCD/CMND", idCtrl),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: bg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: green,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: isSubmitting ? null : _submit,
          child: isSubmitting
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  "Gửi đăng ký",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _heroCard() {
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
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              "https://cl-wpml.careerlink.vn/cam-nang-viec-lam/wp-content/uploads/2023/02/28141652/3692229-1-1024x1024.jpg",
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Đồng hành cùng Pushan Food",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF2F1C14),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Tăng thu nhập với mỗi chuyến giao, luôn được hỗ trợ 24/7.",
                  style: TextStyle(
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, String hint, TextEditingController ctrl,
      {TextInputType type = TextInputType.text}) {
    const borderColor = Color(0xFFE1C59A);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderColor, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 18, color: Color(0xFF1F7A52)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
