import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/data/models/product_model.dart';
import 'package:smart_food_frontend/providers/category_provider.dart';
import 'package:smart_food_frontend/providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController discountCtrl;
  late TextEditingController positionCtrl;

  bool isAvailable = true;
  File? imageFile;
  bool isLoading = false;
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.product.name);
    descCtrl = TextEditingController(text: widget.product.description ?? "");
    priceCtrl = TextEditingController(text: widget.product.price.toString());
    discountCtrl = TextEditingController(
        text: widget.product.discountPrice?.toString() ?? "");
    positionCtrl =
        TextEditingController(text: widget.product.position.toString());
    isAvailable = widget.product.isAvailable;
    selectedCategoryId = widget.product.categoryId;
    Future.microtask(() {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    discountCtrl.dispose();
    positionCtrl.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (nameCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nhập tên và giá")),
      );
      return;
    }

    setState(() => isLoading = true);

    final fields = <String, String>{
      "name": nameCtrl.text.trim(),
      "description": descCtrl.text.trim(),
      "price": priceCtrl.text.trim(),
      "discount_price": discountCtrl.text.trim().isEmpty
          ? ""
          : discountCtrl.text.trim(),
      "is_available": isAvailable.toString(),
      "position": positionCtrl.text.trim(),
    };
    if (selectedCategoryId != null) {
      fields["category"] = selectedCategoryId.toString();
    }

    final ok = await Provider.of<ProductProvider>(context, listen: false)
        .updateProduct(
      id: widget.product.id,
      fields: fields,
      imageFile: imageFile,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật sản phẩm thành công")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể cập nhật")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFF7EF);
    const green = Color(0xFF255B36);
    const borderColor = Color(0xFFE1C59A);

    final categories =
        Provider.of<CategoryProvider>(context).categories;

    final currentImage = imageFile != null
        ? Image.file(imageFile!, fit: BoxFit.cover)
        : ((widget.product.imageUrl ?? widget.product.image) != null &&
                (widget.product.imageUrl ?? widget.product.image)!.isNotEmpty)
            ? Image.network(widget.product.imageUrl ?? widget.product.image!,
                fit: BoxFit.cover)
            : null;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Sửa sản phẩm",
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
                  child: currentImage ??
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
            const SizedBox(height: 20),
            _inputField("Tên sản phẩm *", "Ví dụ: Trà sữa", nameCtrl),
            const SizedBox(height: 14),
            _inputField("Mô tả", "Nhập mô tả", descCtrl, maxLines: 3),
            const SizedBox(height: 14),
            _inputField("Giá *", "VD: 45000", priceCtrl,
                type: TextInputType.number),
            const SizedBox(height: 14),
            _inputField("Giá giảm", "Bỏ trong nếu không", discountCtrl,
                type: TextInputType.number),
            const SizedBox(height: 14),
            _inputField("Thứ tự", "0", positionCtrl,
                type: TextInputType.number),
            const SizedBox(height: 14),
            const Text(
              "Danh mục",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: selectedCategoryId,
                  isExpanded: true,
                  hint: const Text("Chọn danh mục"),
                  items: categories
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => selectedCategoryId = v),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Đang bán",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Switch(
                  value: isAvailable,
                  activeColor: green,
                  onChanged: (v) => setState(() => isAvailable = v),
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

  Widget _inputField(String label, String hint, TextEditingController ctrl,
      {TextInputType type = TextInputType.text, int maxLines = 1}) {
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
