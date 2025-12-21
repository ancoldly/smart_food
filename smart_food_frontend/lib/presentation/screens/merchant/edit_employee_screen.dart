import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/providers/employee_provider.dart';
import 'package:smart_food_frontend/data/models/employee_model.dart';

class EditEmployeeScreen extends StatefulWidget {
  final int employeeId;

  const EditEmployeeScreen({super.key, required this.employeeId});

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  String selectedRole = "staff";

  File? newAvatar; // ảnh mới
  bool isLoading = true;

  EmployeeModel? employee;

  final roleLabelMap = {
    "manager": "Quản lý ca",
    "cashier": "Thu ngân",
    "staff": "Nhân viên",
    "delivery": "Nhân viên giao hàng",
  };

  @override
  void initState() {
    super.initState();
    _loadEmployee();
  }

  Future<void> _loadEmployee() async {
    final provider = Provider.of<EmployeeProvider>(context, listen: false);

    await provider.loadEmployee(widget.employeeId);
    employee = provider.selectedEmployee;

    if (employee == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy nhân viên")),
        );
        Navigator.pop(context);
      }
      return;
    }

    nameCtrl.text = employee!.fullName;
    phoneCtrl.text = employee!.phone;
    emailCtrl.text = employee!.email ?? "";
    selectedRole = employee!.role;

    setState(() => isLoading = false);
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => newAvatar = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Không được để trống")));
      return;
    }

    final provider = Provider.of<EmployeeProvider>(context, listen: false);

    final ok = await provider.updateEmployee(
      id: widget.employeeId,
      fields: {
        "full_name": nameCtrl.text.trim(),
        "phone": phoneCtrl.text.trim(),
        "email": emailCtrl.text.trim(),
        "role": selectedRole,
      },
      avatarImage: newAvatar, // chỉ gửi nếu ảnh mới != null
    );

    if (ok) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Cập nhật thành công")));
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Cập nhật thất bại")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFF7EF);
    const green = Color(0xFF255B36);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chỉnh sửa nhân viên",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: green),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _avatarPicker(),
            const SizedBox(height: 24),

            _inputField("Họ và tên *", nameCtrl),
            const SizedBox(height: 16),

            _inputField("Số điện thoại *", phoneCtrl,
                type: TextInputType.phone),
            const SizedBox(height: 16),

            _inputField("Email", emailCtrl, type: TextInputType.emailAddress),
            const SizedBox(height: 20),

            const Text("Vai trò",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _roleDropdown(),
            const SizedBox(height: 40),

            // BUTTON UPDATE FIXED
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22)),
                ),
                child: const Text(
                  "Cập nhật",
                  style: TextStyle(
                      color: Color(0xFFFBEFD8),
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------
  // AVATAR PICKER WITH ICON
  // --------------------------
  Widget _avatarPicker() {
    const borderColor = Color(0xFFE1C59A);

    // FIX imageProvider — dùng ImageProvider<Object>?
    ImageProvider<Object>? img;

    if (newAvatar != null) {
      img = FileImage(newAvatar!);
    } else if (employee!.avatarImage != null &&
        employee!.avatarImage!.isNotEmpty) {
      img = NetworkImage(employee!.avatarImage!);
    } else {
      img = null;
    }

    return Center(
      child: Stack(
        children: [
          Container(
            height: 110,
            width: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: borderColor),
              image: img != null
                  ? DecorationImage(image: img, fit: BoxFit.cover)
                  : null,
            ),
          ),

          // Icon camera ở góc
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          value: selectedRole,
          items: roleLabelMap.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) => setState(() => selectedRole = v!),
          icon: const Icon(Icons.keyboard_arrow_down, color: green),
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController ctrl, {
    TextInputType type = TextInputType.text,
  }) {
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
            hintText: "",
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
