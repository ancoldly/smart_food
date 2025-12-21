import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/providers/store_provider.dart';
import 'package:smart_food_frontend/data/models/store_model.dart';
import 'package:smart_food_frontend/presentation/screens/client/select_location_screen.dart';

class EditStoreScreen extends StatefulWidget {
  final int storeId;

  const EditStoreScreen({super.key, required this.storeId});

  @override
  State<EditStoreScreen> createState() => _EditStoreScreenState();
}

class _EditStoreScreenState extends State<EditStoreScreen> {
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  final managerNameCtrl = TextEditingController();
  final managerPhoneCtrl = TextEditingController();
  final managerEmailCtrl = TextEditingController();

  // FIXED — MATCH ADD
  String streetCtrl = "";
  String wardCtrl = "";

  double? lat;
  double? lng;

  File? avatarImage;
  File? backgroundImage;

  StoreModel? store;
  bool isLoading = true;
  String selectedCity = "Đà Nẵng";

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    final provider = Provider.of<StoreProvider>(context, listen: false);
    await provider.loadMyStore();

    store = provider.myStore;

    if (store == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    // Load store data
    nameCtrl.text = store!.storeName;
    addressCtrl.text = store!.address;

    managerNameCtrl.text = store!.managerName;
    managerPhoneCtrl.text = store!.managerPhone;
    managerEmailCtrl.text = store!.managerEmail;

    selectedCity = store!.city;
    lat = store!.latitude;
    lng = store!.longitude;

    // FIXED — MATCH ADD (tách address → street + ward nếu hợp lệ)
    final parts = store!.address.split(",");
    if (parts.length >= 2) {
      streetCtrl = parts[0].trim();
      wardCtrl = parts[1].trim();
    }

    setState(() => isLoading = false);
  }

  Future<void> pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => avatarImage = File(picked.path));
  }

  Future<void> pickBackground() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => backgroundImage = File(picked.path));
  }

  // FIXED — MATCH ADD
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

        // GHÉP GIỐNG ADD
        addressCtrl.text = streetCtrl.trim().isEmpty
            ? wardCtrl.trim()
            : "${streetCtrl.trim()}, ${wardCtrl.trim()}";
      });
    }
  }

  Future<void> _submit() async {
    if (nameCtrl.text.isEmpty ||
        addressCtrl.text.isEmpty ||
        managerNameCtrl.text.isEmpty ||
        managerPhoneCtrl.text.isEmpty ||
        managerEmailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Không được để trống")));
      return;
    }

    final provider = Provider.of<StoreProvider>(context, listen: false);

    final ok = await provider.updateStore(
      id: store!.id,
      fields: {
        "store_name": nameCtrl.text.trim(),
        "address": addressCtrl.text.trim(),
        "city": selectedCity,
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

    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Cập nhật thành công")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Lỗi cập nhật")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6ECE3);
    const green = Color(0xFF255B36);
    const borderColor = Color(0xFFE1C59A);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Chỉnh sửa cửa hàng",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: green),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------
            //  AVATAR
            // --------------------------
            const Text("Ảnh đại diện",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: pickAvatar,
              child: Stack(
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(color: borderColor),
                      image: avatarImage != null
                          ? DecorationImage(
                              image: FileImage(avatarImage!), fit: BoxFit.cover)
                          : (store!.avatarImage != null
                              ? DecorationImage(
                                  image: NetworkImage(store!.avatarImage!),
                                  fit: BoxFit.cover)
                              : null),
                    ),
                    child: avatarImage == null && store!.avatarImage == null
                        ? const Icon(Icons.camera_alt_outlined,
                            size: 30, color: Colors.black45)
                        : null,
                  ),

                  // camera icon overlay
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor),
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 18, color: Colors.black54),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --------------------------
            // BACKGROUND
            // --------------------------
            const Text("Ảnh nền cửa hàng",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: pickBackground,
              child: Stack(
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(12),
                      image: backgroundImage != null
                          ? DecorationImage(
                              image: FileImage(backgroundImage!),
                              fit: BoxFit.cover)
                          : (store!.backgroundImage != null
                              ? DecorationImage(
                                  image: NetworkImage(store!.backgroundImage!),
                                  fit: BoxFit.cover)
                              : null),
                    ),
                    child: backgroundImage == null &&
                            store!.backgroundImage == null
                        ? const Icon(Icons.image_outlined,
                            size: 40, color: Colors.black45)
                        : null,
                  ),

                  // camera overlay
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor)),
                      child: const Icon(Icons.camera_alt,
                          size: 20, color: Colors.black54),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 26),

            // --------------------------
            // INPUTS
            // --------------------------
            _inputField("Tên cửa hàng *", "Nhập tên cửa hàng", nameCtrl),
            const SizedBox(height: 16),

            const Text("Thành phố *",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),

            _cityDropdown(),

            const SizedBox(height: 20),

            _inputField(
                "Địa chỉ chi tiết *", "Ví dụ: 270 Trần Đại Nghĩa", addressCtrl),

            // FIXED — MATCH ADD
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
                    style: TextStyle(color: green)),
              ),
            ),

            const SizedBox(height: 26),

            const Text("Thông tin quản lý",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),

            _inputField("Tên quản lý *", "VD: Nguyễn Văn A", managerNameCtrl),
            const SizedBox(height: 10),

            _inputField("SĐT quản lý *", "Nhập số điện thoại", managerPhoneCtrl,
                type: TextInputType.phone),
            const SizedBox(height: 10),

            _inputField("Email quản lý *", "Nhập email", managerEmailCtrl,
                type: TextInputType.emailAddress),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
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

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _cityDropdown() {
    const borderColor = Color(0xFFE1C59A);

    return Container(
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
            DropdownMenuItem(value: "Hà Nội", child: Text("Hà Nội")),
            DropdownMenuItem(value: "Hồ Chí Minh", child: Text("Hồ Chí Minh")),
          ],
          onChanged: (v) => setState(() => selectedCity = v!),
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
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
}
