import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/data/models/category_model.dart';
import 'package:smart_food_frontend/providers/category_provider.dart';

class EditCategoryScreen extends StatefulWidget {
  final CategoryModel category;
  const EditCategoryScreen({super.key, required this.category});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;
  late bool isActive;
  File? imageFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.category.name);
    descCtrl = TextEditingController(text: widget.category.description ?? "");
    isActive = widget.category.isActive;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tên danh mục")),
      );
      return;
    }

    setState(() => isLoading = true);

    final provider = Provider.of<CategoryProvider>(context, listen: false);
    final ok = await provider.updateCategory(
      id: widget.category.id,
      fields: {
        "name": nameCtrl.text.trim(),
        "description": descCtrl.text.trim(),
        "is_active": isActive.toString(),
      },
      imageFile: imageFile,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật danh mục thành công")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể cập nhật danh mục")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFF7EF);
    const green = Color(0xFF255B36);
    const borderColor = Color(0xFFE1C59A);

    final displayImage = imageFile != null
        ? Image.file(imageFile!, fit: BoxFit.cover)
        : (widget.category.imageUrl != null && widget.category.imageUrl!.isNotEmpty)
            ? Image.network(widget.category.imageUrl!, fit: BoxFit.cover)
            : (widget.category.image != null && widget.category.image!.isNotEmpty)
                ? Image.network(widget.category.image!, fit: BoxFit.cover)
                : null;

    return Scaffold(
      backgroundColor: bg,
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
          "Sửa danh mục",
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
            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: displayImage ??
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_camera_outlined,
                              size: 30, color: Colors.black54),
                          SizedBox(height: 6),
                          Text("Chọn ảnh",
                              style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _inputField(
              label: "Tên danh mục *",
              hint: "VD: Trà sữa",
              controller: nameCtrl,
            ),
            const SizedBox(height: 16),
            _inputField(
              label: "Mô tả",
              hint: "Nhập mô tả ngắn",
              controller: descCtrl,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Kích hoạt",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Switch(
                  value: isActive,
                  activeColor: green,
                  onChanged: (v) => setState(() => isActive = v),
                ),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
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
                  "Lưu thay đổi",
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

  Widget _inputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    const borderColor = Color(0xFFE1C59A);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
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
