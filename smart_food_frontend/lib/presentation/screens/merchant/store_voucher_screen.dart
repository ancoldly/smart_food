import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/store_voucher_model.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';

class StoreVoucherScreen extends StatefulWidget {
  const StoreVoucherScreen({super.key});

  @override
  State<StoreVoucherScreen> createState() => _StoreVoucherScreenState();
}

class _StoreVoucherScreenState extends State<StoreVoucherScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      setState(() => _loading = true);
      await Provider.of<StoreProvider>(context, listen: false)
          .loadStoreVouchers();
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeP = Provider.of<StoreProvider>(context);
    final vouchers = storeP.storeVouchers;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Mã giảm giá cửa hàng",
          style: TextStyle(
            color: Color(0xFF391713),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1F7A52),
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : vouchers.isEmpty
              ? const Center(
                  child: Text(
                    "Chưa có mã giảm giá",
                    style: TextStyle(color: Color(0xFF391713), fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: vouchers.length,
                  itemBuilder: (context, index) {
                    final v = vouchers[index];
                    return _voucherCard(context, v);
                  },
                ),
    );
  }

  Widget _voucherCard(BuildContext context, StoreVoucherModel v) {
    final isPercent = v.discountType == "percent";
    final discountText = isPercent
        ? "${v.discountValue.toStringAsFixed(0)}%"
        : "${v.discountValue.toStringAsFixed(0)}đ";
    final dateText = _rangeDate(v.startDate, v.endDate);
    final isActive = v.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2E5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  discountText,
                  style: const TextStyle(
                    color: Color(0xFF9A1B1D),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                if (v.maxDiscountValue != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Tối đa ${v.maxDiscountValue!.toStringAsFixed(0)}đ",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF9A1B1D),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        v.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF391713),
                        ),
                      ),
                    ),
                    Switch(
                      value: isActive,
                      activeColor: const Color(0xFF1F7A52),
                      onChanged: (val) {
                        _updateVoucher(v.id, {"is_active": val});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _tagChip(
                        isActive ? "Đang bật" : "Đang tắt",
                        isActive ? const Color(0xFF1F7A52) : Colors.red),
                    _tagChip(dateText, const Color(0xFF9A1B1D)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  v.description.isNotEmpty ? v.description : "Không có mô tả",
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Đơn tối thiểu: ${v.minOrderValue.toStringAsFixed(0)}đ",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF391713),
                      ),
                    ),
                    Text(
                      "Đã dùng: ${v.usedCount}/${v.usageLimit ?? '-'}",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _openForm(context, voucher: v),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text("Sửa"),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(v.id),
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      label: const Text(
                        "Xóa",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _rangeDate(String? start, String? end) {
    String? fmt(String? iso) {
      if (iso == null) return null;
      if (iso.length >= 10) return iso.substring(0, 10);
      return iso;
    }

    final s = fmt(start);
    final e = fmt(end);
    if (s == null && e == null) return "Không giới hạn thời gian";
    if (s != null && e != null) return "$s - $e";
    if (s != null) return "Từ $s";
    return "Đến $e";
  }

  Widget _tagChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context,
      {StoreVoucherModel? voucher}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _VoucherForm(voucher: voucher),
    );
    if (result == true && mounted) {
      await Provider.of<StoreProvider>(context, listen: false)
          .loadStoreVouchers();
    }
  }

  Future<void> _updateVoucher(int id, Map<String, dynamic> data) async {
    await Provider.of<StoreProvider>(context, listen: false)
        .updateStoreVoucher(id, data);
  }

  Future<void> _confirmDelete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa voucher"),
        content:
            const Text("Bạn có chắc chắn muốn xóa mã giảm giá này?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Xóa",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await Provider.of<StoreProvider>(context, listen: false)
          .deleteStoreVoucher(id);
    }
  }
}

class _VoucherForm extends StatefulWidget {
  final StoreVoucherModel? voucher;
  const _VoucherForm({this.voucher});

  @override
  State<_VoucherForm> createState() => _VoucherFormState();
}

class _VoucherFormState extends State<_VoucherForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeC;
  late TextEditingController _descC;
  late TextEditingController _discountValueC;
  late TextEditingController _minOrderC;
  late TextEditingController _maxDiscountC;
  late TextEditingController _usageLimitC;
  String _discountType = "percent";
  bool _isActive = true;
  String? _startDate;
  String? _endDate;

  @override
  void initState() {
    super.initState();
    final v = widget.voucher;
    _codeC = TextEditingController(text: v?.code ?? "");
    _descC = TextEditingController(text: v?.description ?? "");
    _discountValueC = TextEditingController(
        text: v != null ? v.discountValue.toStringAsFixed(0) : "");
    _minOrderC = TextEditingController(
        text: v != null ? v.minOrderValue.toStringAsFixed(0) : "");
    _maxDiscountC = TextEditingController(
        text: v?.maxDiscountValue != null
            ? v!.maxDiscountValue!.toStringAsFixed(0)
            : "");
    _usageLimitC = TextEditingController(
        text: v?.usageLimit != null ? v!.usageLimit.toString() : "");
    _discountType = v?.discountType ?? "percent";
    _isActive = v?.isActive ?? true;
    _startDate = v?.startDate;
    _endDate = v?.endDate;
  }

  @override
  void dispose() {
    _codeC.dispose();
    _descC.dispose();
    _discountValueC.dispose();
    _minOrderC.dispose();
    _maxDiscountC.dispose();
    _usageLimitC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.voucher != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? "Sửa mã giảm giá" : "Tạo mã giảm giá",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF391713),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
              const SizedBox(height: 12),
              _input(
                label: "Mã",
                controller: _codeC,
                validator: (v) =>
                    v == null || v.isEmpty ? "Nhập mã giảm giá" : null,
              ),
              _input(
                label: "Mô tả",
                controller: _descC,
                maxLines: 2,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _discountType,
                      decoration: const InputDecoration(
                        labelText: "Loại giảm",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "percent",
                          child: Text("Giảm %"),
                        ),
                        DropdownMenuItem(
                          value: "fixed",
                          child: Text("Giảm tiền"),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _discountType = val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _input(
                      label: _discountType == "percent"
                          ? "Giá trị (%)"
                          : "Giá trị (đ)",
                      controller: _discountValueC,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? "Nhập giá trị" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _input(
                label: "Đơn hàng tối thiểu (đ)",
                controller: _minOrderC,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _input(
                label: "Giảm tối đa (đ, tùy chọn)",
                controller: _maxDiscountC,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _input(
                label: "Giới hạn lượt dùng (tùy chọn)",
                controller: _usageLimitC,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _dateField(
                      label: "Bắt đầu",
                      value: _startDate,
                      onPick: (val) => setState(() => _startDate = val),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dateField(
                      label: "Kết thúc",
                      value: _endDate,
                      onPick: (val) => setState(() => _endDate = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "Kích hoạt",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F7A52),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submit,
                  child: Text(
                    isEdit ? "Lưu thay đổi" : "Tạo mới",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required String? value,
    required ValueChanged<String?> onPick,
  }) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 2),
          initialDate: now,
        );
        if (picked != null) {
          onPick("${picked.year}-${_two(picked.month)}-${_two(picked.day)}");
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        child: Text(value ?? "Chưa chọn"),
      ),
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final payload = {
      "code": _codeC.text.trim(),
      "description": _descC.text.trim(),
      "discount_type": _discountType,
      "discount_value": double.tryParse(_discountValueC.text) ?? 0,
      "min_order_value": double.tryParse(_minOrderC.text) ?? 0,
      "max_discount_value": _maxDiscountC.text.isNotEmpty
          ? double.tryParse(_maxDiscountC.text)
          : null,
      "usage_limit":
          _usageLimitC.text.isNotEmpty ? int.tryParse(_usageLimitC.text) : null,
      "start_date": _startDate,
      "end_date": _endDate,
      "is_active": _isActive,
    };

    final storeP = Provider.of<StoreProvider>(context, listen: false);
    final isEdit = widget.voucher != null;
    bool ok = false;
    if (isEdit) {
      ok = await storeP.updateStoreVoucher(widget.voucher!.id, payload);
    } else {
      ok = await storeP.createStoreVoucher(payload);
    }

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lưu voucher thất bại")),
      );
    }
  }
}
