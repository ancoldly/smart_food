import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/providers/employee_provider.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  File? avatarImage;

  bool isLoading = false;

  /// Role hiển thị cho UI
  String selectedRoleLabel = "Quản lý ca";

  /// Map UI → backend
  final Map<String, String> roleMap = {
    "Nhân viên": "staff",
    "Thu ngân": "cashier",
    "Quản lý ca": "manager",
    "Nhân viên giao hàng nội bộ": "delivery",
  };

  Future<void> pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => avatarImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (nameCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        selectedRoleLabel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final store = storeProvider.myStore;

    setState(() => isLoading = true);

    final provider = Provider.of<EmployeeProvider>(context, listen: false);

    final success = await provider.addEmployee(
      fields: {
        "store": store?.id.toString() ?? "",
        "full_name": nameCtrl.text.trim(),
        "phone": phoneCtrl.text.trim(),
        "email": emailCtrl.text.trim(),
        "role": roleMap[selectedRoleLabel]!, // convert đúng backend
      },
      avatarImage: avatarImage,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thêm nhân viên thành công")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể thêm nhân viên")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFF7EF);
    const green = Color(0xFF255B36);
    const borderColor = Color(0xFFE1C59A);

    return Scaffold(
      backgroundColor: bg,

      // ===========================
      //          APPBAR
      // ===========================
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Thêm nhân viên",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: green),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===========================
            //       AVATAR PICKER
            // ===========================
            Center(
              child: GestureDetector(
                onTap: pickAvatar,
                child: Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(color: borderColor),
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
                                  size: 32, color: Colors.black45),
                              SizedBox(height: 6),
                              Text("Chọn ảnh",
                                  style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 24),

            _inputField("Họ và tên *", "Ví dụ: Nguyễn Văn A", nameCtrl),
            const SizedBox(height: 16),

            _inputField("Số điện thoại *", "Nhập số điện thoại", phoneCtrl,
                type: TextInputType.phone),
            const SizedBox(height: 16),

            _inputField("Email", "Nhập email", emailCtrl,
                type: TextInputType.emailAddress),
            const SizedBox(height: 20),

            const Text(
              "Chọn vai trò",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            _roleDropdown(),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // ===========================
      //     BUTTON SUBMIT
      // ===========================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        color: bg,
        child: ElevatedButton(
          onPressed: isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: green,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  "Thêm nhân viên",
                  style: TextStyle(
                    color: Color(0xFFFBEFD8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  // ===========================
  //      INPUT FIELD
  // ===========================
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

  // ===========================
  //      ROLE DROPDOWN
  // ===========================
  Widget _roleDropdown() {
    const borderColor = Color(0xFFE1C59A);
    const green = Color(0xFF255B36);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedRoleLabel,
          items: const [
            DropdownMenuItem(value: "Quản lý ca", child: Text("Quản lý ca")),
            DropdownMenuItem(value: "Thu ngân", child: Text("Thu ngân")),
            DropdownMenuItem(value: "Nhân viên", child: Text("Nhân viên")),
            DropdownMenuItem(
                value: "Nhân viên giao hàng nội bộ",
                child: Text("Nhân viên giao hàng nội bộ")),
          ],
          onChanged: (v) => setState(() => selectedRoleLabel = v!),
          icon: const Icon(Icons.keyboard_arrow_down, color: green),
        ),
      ),
    );
  }
}
