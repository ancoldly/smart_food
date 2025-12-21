import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/data/models/option_group_template_model.dart';
import 'package:smart_food_frontend/data/models/option_template_model.dart';
import 'package:smart_food_frontend/providers/option_template_provider.dart';

class AddEditTemplateOptionScreen extends StatefulWidget {
  final OptionGroupTemplateModel group;
  final OptionTemplateModel? option;
  const AddEditTemplateOptionScreen({super.key, required this.group, this.option});

  @override
  State<AddEditTemplateOptionScreen> createState() => _AddEditTemplateOptionScreenState();
}

class _AddEditTemplateOptionScreenState extends State<AddEditTemplateOptionScreen> {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController(text: "0");
  final positionCtrl = TextEditingController(text: "0");
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.option != null) {
      nameCtrl.text = widget.option!.name;
      priceCtrl.text = widget.option!.price.toString();
      positionCtrl.text = widget.option!.position.toString();
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    positionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Nhập tên lựa chọn")));
      return;
    }
    setState(() => isLoading = true);
    final body = {
      "option_group_template": widget.group.id,
      "name": nameCtrl.text.trim(),
      "price": double.tryParse(priceCtrl.text.trim()) ?? 0,
      "position": int.tryParse(positionCtrl.text.trim()) ?? 0,
    };
    final provider = Provider.of<OptionTemplateProvider>(context, listen: false);
    bool ok;
    if (widget.option == null) {
      ok = await provider.addOption(body);
    } else {
      ok = await provider.updateOption(widget.option!.id, body);
    }
    if (!mounted) return;
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? "Lưu thành công" : "Không thể lưu")),
    );
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFFF7EF);
    const green = Color(0xFF255B36);

    final title = widget.option == null ? "Thêm lựa chọn" : "Sửa lựa chọn";

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
        title: Text(
          title,
          style: const TextStyle(
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
            _inputField("Tên lựa chọn *", "Ví dụ: Size M", nameCtrl),
            const SizedBox(height: 14),
            _inputField("Giá", "0", priceCtrl, type: TextInputType.number),
            const SizedBox(height: 14),
            _inputField("Thứ tự", "0", positionCtrl, type: TextInputType.number),
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
                  "Lưu",
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
