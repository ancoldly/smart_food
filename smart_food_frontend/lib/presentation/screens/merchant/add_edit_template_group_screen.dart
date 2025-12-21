import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/data/models/option_group_template_model.dart';
import 'package:smart_food_frontend/providers/option_group_template_provider.dart';

class AddEditTemplateGroupScreen extends StatefulWidget {
  final OptionGroupTemplateModel? group;
  const AddEditTemplateGroupScreen({super.key, this.group});

  @override
  State<AddEditTemplateGroupScreen> createState() =>
      _AddEditTemplateGroupScreenState();
}

class _AddEditTemplateGroupScreenState
    extends State<AddEditTemplateGroupScreen> {
  final nameCtrl = TextEditingController();
  final maxCtrl = TextEditingController(text: "1");
  final positionCtrl = TextEditingController(text: "0");
  bool isRequired = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      nameCtrl.text = widget.group!.name;
      maxCtrl.text = widget.group!.maxSelect.toString();
      positionCtrl.text = widget.group!.position.toString();
      isRequired = widget.group!.isRequired;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    maxCtrl.dispose();
    positionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Nhập tên nhóm")));
      return;
    }
    setState(() => isLoading = true);
    final body = {
      "name": nameCtrl.text.trim(),
      "is_required": isRequired,
      "max_select": int.tryParse(maxCtrl.text.trim()) ?? 1,
      "position": int.tryParse(positionCtrl.text.trim()) ?? 0,
    };
    final provider =
        Provider.of<OptionGroupTemplateProvider>(context, listen: false);
    bool ok;
    if (widget.group == null) {
      ok = await provider.addGroup(body);
    } else {
      ok = await provider.updateGroup(widget.group!.id, body);
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

    final title =
        widget.group == null ? "Thêm nhóm chung" : "Sửa nhóm chung";

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
            _inputField("Tên nhóm *", "Ví dụ: Size chung", nameCtrl),
            const SizedBox(height: 14),
            _inputField("Max chọn (0 = không giới hạn)", "1", maxCtrl,
                type: TextInputType.number),
            const SizedBox(height: 14),
            _inputField("Thứ tự", "0", positionCtrl,
                type: TextInputType.number),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Bắt buộc chọn",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Switch(
                  value: isRequired,
                  activeColor: green,
                  onChanged: (v) => setState(() => isRequired = v),
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
