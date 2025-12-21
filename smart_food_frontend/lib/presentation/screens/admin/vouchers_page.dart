import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/data/models/voucher_model.dart';
import 'package:smart_food_frontend/providers/voucher_provider.dart';

class VouchersPage extends StatefulWidget {
  const VouchersPage({super.key});

  @override
  State<VouchersPage> createState() => _VouchersPageState();
}

class _VouchersPageState extends State<VouchersPage> {
  final DateFormat _df = DateFormat("dd/MM/yyyy HH:mm");

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<VoucherProvider>(context, listen: false).loadAdmin());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VoucherProvider>(context);
    final vouchers = provider.adminVouchers;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Voucher Manager",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openVoucherSheet(context),
        child: const Icon(Icons.add),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vouchers.length,
              itemBuilder: (context, index) {
                final item = vouchers[index];
                return _voucherCard(item);
              },
            ),
    );
  }

  Widget _voucherCard(VoucherModel item) {
    final isPercent = item.discountType == "percent";
    final discountText = isPercent
        ? "${item.discountValue.toStringAsFixed(0)}%"
        : "${_formatMoney(item.discountValue)}đ";
    final minOrderText = _formatMoney(item.minOrderAmount);
    final timeText =
        "${item.startAt != null ? _df.format(item.startAt!) : '-'} → ${item.endAt != null ? _df.format(item.endAt!) : '-'}";
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          "${item.code} - ${item.title}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text("Giảm: $discountText"),
            if (isPercent && item.maxDiscountAmount != null)
              Text("Tối đa: ${_formatMoney(item.maxDiscountAmount!)}đ"),
            Text("ĐH tối thiểu: $minOrderTextđ"),
            Text("Hiệu lực: $timeText"),
            Text(
                "Lượt dùng: ${item.usedCount}/${item.usageLimitTotal ?? '∞'} | Mỗi user: ${item.usageLimitPerUser}"),
            const SizedBox(height: 8),
            Chip(
              label: Text(isPercent ? "Percent" : "Amount"),
              backgroundColor: isPercent
                  ? Colors.blue.withOpacity(0.15)
                  : Colors.green.withOpacity(0.15),
              labelStyle: TextStyle(
                color: isPercent ? Colors.blue : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _openVoucherSheet(context, voucher: item),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(item.id),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int id) async {
    final provider = Provider.of<VoucherProvider>(context, listen: false);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa voucher?"),
        content: const Text("Thao tác này không thể hoàn tác."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa")),
        ],
      ),
    );
    if (ok == true) {
      final res = await provider.deleteAdmin(id);
      if (!res && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Xóa thất bại")));
      }
    }
  }

  void _openVoucherSheet(BuildContext context, {VoucherModel? voucher}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => VoucherFormSheet(voucher: voucher),
    );
  }

  String _formatMoney(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.");
  }
}

class VoucherFormSheet extends StatefulWidget {
  final VoucherModel? voucher;
  const VoucherFormSheet({super.key, this.voucher});

  @override
  State<VoucherFormSheet> createState() => _VoucherFormSheetState();
}

class _VoucherFormSheetState extends State<VoucherFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController codeCtrl = TextEditingController();
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController discountValueCtrl = TextEditingController();
  final TextEditingController maxDiscountCtrl = TextEditingController();
  final TextEditingController minOrderCtrl = TextEditingController();
  final TextEditingController usageTotalCtrl = TextEditingController();
  final TextEditingController usagePerUserCtrl = TextEditingController(text: "1");
  DateTime? startAt;
  DateTime? endAt;
  String discountType = "percent";

  @override
  void initState() {
    super.initState();
    final v = widget.voucher;
    if (v != null) {
      codeCtrl.text = v.code;
      titleCtrl.text = v.title;
      descCtrl.text = v.description ?? "";
      discountType = v.discountType;
      discountValueCtrl.text = v.discountValue.toString();
      if (v.maxDiscountAmount != null) {
        maxDiscountCtrl.text = v.maxDiscountAmount!.toString();
      }
      minOrderCtrl.text = v.minOrderAmount.toString();
      if (v.usageLimitTotal != null) usageTotalCtrl.text = v.usageLimitTotal!.toString();
      usagePerUserCtrl.text = v.usageLimitPerUser.toString();
      startAt = v.startAt;
      endAt = v.endAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.voucher != null;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEdit ? "Cập nhật voucher" : "Tạo voucher",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _input("Mã voucher", codeCtrl, requiredField: true, upper: true),
                  const SizedBox(height: 12),
                  _input("Tiêu đề", titleCtrl, requiredField: true),
                  const SizedBox(height: 12),
                  _input("Mô tả", descCtrl, maxLines: 2),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _input("Giá trị giảm", discountValueCtrl,
                            requiredField: true, keyboard: TextInputType.number),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _input("Giảm tối đa (nếu %)", maxDiscountCtrl,
                            keyboard: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _input("Đơn tối thiểu", minOrderCtrl,
                      requiredField: true, keyboard: TextInputType.number),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _datePickerField("Bắt đầu", startAt,
                            onPick: (dt) => setState(() => startAt = dt)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _datePickerField("Kết thúc", endAt,
                            onPick: (dt) => setState(() => endAt = dt)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _input("Giới hạn tổng (để trống = ∞)", usageTotalCtrl,
                            keyboard: TextInputType.number),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _input("Giới hạn / user", usagePerUserCtrl,
                            requiredField: true, keyboard: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          value: "percent",
                          groupValue: discountType,
                          title: const Text("Giảm %"),
                          onChanged: (v) => setState(() => discountType = v ?? "percent"),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          value: "fixed",
                          groupValue: discountType,
                          title: const Text("Giảm số tiền"),
                          onChanged: (v) => setState(() => discountType = v ?? "fixed"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(isEdit ? "Cập nhật" : "Tạo"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _input(String label, TextEditingController ctrl,
      {bool requiredField = false,
      int maxLines = 1,
      TextInputType keyboard = TextInputType.text,
      bool upper = false}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      inputFormatters: upper ? [UpperCaseTextFormatter()] : null,
      validator: (v) {
        if (requiredField && (v == null || v.trim().isEmpty)) {
          return "Bắt buộc";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _datePickerField(String label, DateTime? value,
      {required ValueChanged<DateTime> onPick}) {
    final text = value != null ? DateFormat("dd/MM/yyyy HH:mm").format(value) : "Chọn";
    return OutlinedButton(
      onPressed: () async {
        final now = DateTime.now();
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 3),
        );
        if (pickedDate != null) {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: value != null
                ? TimeOfDay.fromDateTime(value)
                : TimeOfDay.fromDateTime(now),
          );
          final dt = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime?.hour ?? 0,
            pickedTime?.minute ?? 0,
          );
          onPick(dt);
        }
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<VoucherProvider>(context, listen: false);

    double? toDouble(String v) {
      if (v.trim().isEmpty) return null;
      return double.tryParse(v);
    }

    final body = {
      "code": codeCtrl.text.trim(),
      "title": titleCtrl.text.trim(),
      "description": descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null,
      "discount_type": discountType,
      "discount_value": toDouble(discountValueCtrl.text) ?? 0,
      "max_discount_amount": toDouble(maxDiscountCtrl.text),
      "min_order_amount": toDouble(minOrderCtrl.text) ?? 0,
      "usage_limit_total":
          usageTotalCtrl.text.trim().isNotEmpty ? int.tryParse(usageTotalCtrl.text) : null,
      "usage_limit_per_user": int.tryParse(usagePerUserCtrl.text) ?? 1,
      "start_at": startAt?.toIso8601String(),
      "end_at": endAt?.toIso8601String(),
      "is_active": true,
    };

    bool ok;
    if (widget.voucher == null) {
      ok = await provider.createAdmin(body);
    } else {
      ok = await provider.updateAdmin(widget.voucher!.id, body);
    }

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? "Lưu voucher thành công" : "Lưu voucher thất bại"),
    ));
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
