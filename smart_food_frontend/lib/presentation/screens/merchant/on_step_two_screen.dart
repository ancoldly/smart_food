import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/providers/store_provider.dart';
import 'package:smart_food_frontend/providers/user_provider.dart';
import 'package:smart_food_frontend/presentation/screens/client/select_location_screen.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';

class OnStepTwoScreen extends StatefulWidget {
  final String category;
  const OnStepTwoScreen({super.key, required this.category});

  @override
  State<OnStepTwoScreen> createState() => _OnStepTwoScreenState();
}

class _OnStepTwoScreenState extends State<OnStepTwoScreen> {
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  final managerNameCtrl = TextEditingController();
  final managerPhoneCtrl = TextEditingController();
  final managerEmailCtrl = TextEditingController();

  String streetCtrl = "";
  String wardCtrl = "";

  double? lat;
  double? lng;

  /// NEW — 2 ảnh riêng biệt
  File? avatarImage;
  File? backgroundImage;

  bool isLoading = false;
  String selectedCity = "Đà Nẵng";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    if (user != null) {
      managerEmailCtrl.text = user.email;
      managerPhoneCtrl.text = user.phone ?? "";
      managerNameCtrl.text = user.fullName ?? "";
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    addressCtrl.dispose();
    managerNameCtrl.dispose();
    managerPhoneCtrl.dispose();
    managerEmailCtrl.dispose();
    super.dispose();
  }

  /// Pick avatar
  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => avatarImage = File(picked.path));
  }

  /// Pick background
  Future<void> _pickBackground() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => backgroundImage = File(picked.path));
  }

  Future<void> _openMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectLocationScreen()),
    );

    if (result != null) {
      setState(() {
        lat = result["lat"];
        lng = result["lng"];
        streetCtrl = result["street"] ?? "";
        wardCtrl = result["ward"] ?? "";

        addressCtrl.text = streetCtrl.trim().isEmpty
            ? wardCtrl.trim()
            : "${streetCtrl.trim()}, ${wardCtrl.trim()}";
      });
    }
  }

  Future<void> _submitStore() async {
    if (nameCtrl.text.isEmpty ||
        addressCtrl.text.isEmpty ||
        managerNameCtrl.text.isEmpty ||
        managerPhoneCtrl.text.isEmpty ||
        managerEmailCtrl.text.isEmpty ||
        lat == null ||
        lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await Provider.of<StoreProvider>(context, listen: false)
        .addStore(
      fields: {
        "category": widget.category,
        "store_name": nameCtrl.text.trim(),
        "city": selectedCity,
        "address": addressCtrl.text.trim(),
        "manager_name": managerNameCtrl.text.trim(),
        "manager_phone": managerPhoneCtrl.text.trim(),
        "manager_email": managerEmailCtrl.text.trim(),
        "latitude": lat.toString(),
        "longitude": lng.toString(),
      },
      avatarImage: avatarImage,
      backgroundImage: backgroundImage,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tạo cửa hàng thành công")));
      Navigator.popAndPushNamed(context, AppRoutes.merchantPending);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể tạo cửa hàng")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6ECE3);
    const line = Color(0xFF546F41);
    const green = Color(0xFF255B36);
    const titleColor = Color(0xFF222222);
    const borderColor = Color(0xFFE1C59A);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bg,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios,
                  size: 18, color: Colors.black87),
            ),
            const SizedBox(width: 4),
            const Text(
              "Bước 2 trên 2",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: line),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =============================
            //       AVATAR IMAGE
            // =============================
            const Text("Ảnh đại diện quán",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: titleColor)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickAvatar,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(60),
                  image: avatarImage != null
                      ? DecorationImage(
                          image: FileImage(avatarImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: avatarImage == null
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt_outlined,
                                size: 30, color: Colors.black54),
                            SizedBox(height: 6),
                            Text("Chọn avatar",
                                style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 26),

            // =============================
            //       BACKGROUND IMAGE
            // =============================
            const Text("Ảnh nền cửa hàng",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: titleColor)),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: _pickBackground,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(14),
                  image: backgroundImage != null
                      ? DecorationImage(
                          image: FileImage(backgroundImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: backgroundImage == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined,
                                size: 40, color: Colors.black45),
                            SizedBox(height: 6),
                            Text("Chọn ảnh nền",
                                style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 26),

            // =============================
            //     REST OF YOUR UI (KEEP)
            // =============================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFD3E6D6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Vui lòng nhập tên quán theo cấu trúc “Tên quán - Tên món ăn hoặc tên đường”",
                    style: TextStyle(
                      color: Color(0xFF255B36),
                      fontSize: 14,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Ví dụ: Mixue - Trà chanh kẹo mút - Nguyễn Văn Linh",
                    style: TextStyle(
                      color: Color(0xFF255B36),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _inputField("Tên cửa hàng/quán *", "Nhập tên cửa hàng", nameCtrl),
            const SizedBox(height: 16),

            const Text("Thành phố *",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCity,
                  items: const [
                    DropdownMenuItem(value: "Đà Nẵng", child: Text("Đà Nẵng")),
                    DropdownMenuItem(value: "Hồ Chí Minh", child: Text("Hồ Chí Minh")),
                    DropdownMenuItem(value: "Hà Nội", child: Text("Hà Nội")),
                  ],
                  onChanged: (v) => setState(() => selectedCity = v!),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _inputField("Địa chỉ chi tiết *",
                "Ví dụ: 152 Lê Thiện Trị...", addressCtrl),

            if (lat != null) ...[
              const SizedBox(height: 6),
              const Text("Vị trí đã chọn:",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text("Lat: $lat\nLng: $lng",
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],

            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _openMap,
                icon: const Icon(Icons.location_on_outlined, color: green),
                label: const Text("Chọn trên bản đồ",
                    style: TextStyle(color: green, fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 28),

            const Text("Thông tin quản lý",
                style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),

            _inputField("Họ và tên quản lý *", "VD: Nguyễn Văn A", managerNameCtrl),
            const SizedBox(height: 10),
            _inputField("Số điện thoại quản lý *", "Nhập số điện thoại",
                managerPhoneCtrl, type: TextInputType.phone),
            const SizedBox(height: 10),
            _inputField("Email quản lý *", "Nhập email", managerEmailCtrl,
                type: TextInputType.emailAddress),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitStore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Hoàn thành",
                        style: TextStyle(
                          color: Color(0xFFFBEFD8),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, String hint, TextEditingController ctrl,
      {TextInputType type = TextInputType.text}) {
    const borderColor = Color(0xFFE1C59A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600)),
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
              borderSide:
                  const BorderSide(color: borderColor, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
