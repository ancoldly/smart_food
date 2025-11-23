import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/providers/user_provider.dart';
import 'package:smart_food_frontend/presentation/widgets/change_password_sheet.dart';
import 'package:smart_food_frontend/presentation/widgets/input_field.dart'
    as input_field;

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  File? _avatarFile;

  late TextEditingController fullNameController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();

    final user = Provider.of<UserProvider>(context, listen: false).user;

    fullNameController = TextEditingController(text: user?.fullName ?? "");
    phoneController = TextEditingController(text: user?.phone ?? "");
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final success = await userProvider.updateProfile(
      fullName: fullNameController.text.trim(),
      phone: phoneController.text.trim(),
      avatarFile: _avatarFile,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật hồ sơ thành công")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thất bại")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    final email = user?.email ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5B7B56)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Hồ sơ của tôi",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: _avatarFile != null
                        ? FileImage(_avatarFile!)
                        : (user?.avatar != null && user!.avatar!.isNotEmpty)
                            ? NetworkImage(user.avatar!)
                            : const AssetImage(
                                    "assets/images/default_avatar.png")
                                as ImageProvider,
                  ),

                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12, width: 1),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Color(0xFF5B7B56), 
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            input_field.InputField(
              label: "Tên người dùng",
              controller: fullNameController,
            ),
            const SizedBox(height: 18),
            input_field.InputField(
              label: "Email",
              controller: TextEditingController(text: email),
              readOnly: true,
            ),
            const SizedBox(height: 18),
            input_field.InputField(
              label: "Số điện thoại",
              controller: phoneController,
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  showChangePasswordSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFF4CF73),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Đổi mật khẩu",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF5B7B56),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, color: Color(0xFF5B7B56)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 150),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: userProvider.isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF5B7B56),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: userProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Cập nhật hồ sơ",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
