import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/store_campaign_model.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';

class StoreCampaignScreen extends StatefulWidget {
  const StoreCampaignScreen({super.key});

  @override
  State<StoreCampaignScreen> createState() => _StoreCampaignScreenState();
}

class _StoreCampaignScreenState extends State<StoreCampaignScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      setState(() => _loading = true);
      await Provider.of<StoreProvider>(context, listen: false)
          .loadStoreCampaigns();
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final campaigns = storeProvider.campaigns;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Quảng cáo cửa hàng",
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
          : campaigns.isEmpty
              ? const Center(
                  child: Text(
                    "Chưa có chiến dịch nào",
                    style: TextStyle(color: Color(0xFF391713), fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: campaigns.length,
                  itemBuilder: (context, index) {
                    final c = campaigns[index];
                    return _campaignCard(c);
                  },
                ),
    );
  }

  Widget _campaignCard(StoreCampaignModel c) {
    final dateText = _rangeDate(c.startDate, c.endDate);
    final budgetText =
        c.budget > 0 ? "${c.budget.toStringAsFixed(0)} đ" : "Chưa đặt ngân sách";

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: c.bannerUrl.isNotEmpty
                    ? Image.network(
                        c.bannerUrl,
                        width: 90,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
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
                            c.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF391713),
                            ),
                          ),
                        ),
                        Switch(
                          value: c.isActive,
                          activeColor: const Color(0xFF1F7A52),
                          onChanged: (val) {
                            _updateCampaign(c.id, {"is_active": val});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _tagChip(
                          c.isActive ? "Đang bật" : "Đang tắt",
                          c.isActive ? const Color(0xFF1F7A52) : Colors.red,
                        ),
                        if (dateText != null)
                          _tagChip(dateText, const Color(0xFF9A1B1D)),
                        _tagChip(budgetText, const Color(0xFF9A5B2B)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (c.description.isNotEmpty)
            Text(
              c.description,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              _metric(
                icon: Icons.visibility,
                label: "Hiển thị",
                value: c.impressions.toString(),
              ),
              const SizedBox(width: 12),
              _metric(
                icon: Icons.touch_app,
                label: "Lượt nhấn",
                value: c.clicks.toString(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _openForm(context, campaign: c),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text("Sửa"),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _confirmDelete(c.id),
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
    );
  }

  Widget _metric({required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F0E7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF9A5B2B)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B4A2C)),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF391713),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 90,
      height: 80,
      color: const Color(0xFFFFF2E5),
      child: const Icon(Icons.image, color: Color(0xFF9A5B2B)),
    );
  }

  String? _rangeDate(String? start, String? end) {
    String? fmt(String? iso) {
      if (iso == null) return null;
      if (iso.length >= 10) return iso.substring(0, 10);
      return iso;
    }

    final s = fmt(start);
    final e = fmt(end);
    if (s == null && e == null) return null;
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
      {StoreCampaignModel? campaign}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CampaignForm(campaign: campaign),
    );
    if (result == true && mounted) {
      await Provider.of<StoreProvider>(context, listen: false)
          .loadStoreCampaigns();
    }
  }

  Future<void> _updateCampaign(int id, Map<String, dynamic> data) async {
    await Provider.of<StoreProvider>(context, listen: false)
        .updateStoreCampaign(id, data);
  }

  Future<void> _confirmDelete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa chiến dịch"),
        content: const Text("Bạn chắc chắn muốn xóa chiến dịch này?"),
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
          .deleteStoreCampaign(id);
    }
  }
}

class _CampaignForm extends StatefulWidget {
  final StoreCampaignModel? campaign;
  const _CampaignForm({this.campaign});

  @override
  State<_CampaignForm> createState() => _CampaignFormState();
}

class _CampaignFormState extends State<_CampaignForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleC;
  late TextEditingController _descC;
  late TextEditingController _bannerC;
  late TextEditingController _budgetC;
  bool _isActive = true;
  String? _startDate;
  String? _endDate;

  @override
  void initState() {
    super.initState();
    final c = widget.campaign;
    _titleC = TextEditingController(text: c?.title ?? "");
    _descC = TextEditingController(text: c?.description ?? "");
    _bannerC = TextEditingController(text: c?.bannerUrl ?? "");
    _budgetC = TextEditingController(
        text: c != null && c.budget > 0 ? c.budget.toStringAsFixed(0) : "");
    _isActive = c?.isActive ?? true;
    _startDate = c?.startDate;
    _endDate = c?.endDate;
  }

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    _bannerC.dispose();
    _budgetC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.campaign != null;
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
                    isEdit ? "Sửa chiến dịch" : "Tạo chiến dịch",
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
                label: "Tiêu đề",
                controller: _titleC,
                validator: (v) =>
                    v == null || v.isEmpty ? "Nhập tiêu đề" : null,
              ),
              _input(
                label: "Mô tả",
                controller: _descC,
                maxLines: 3,
              ),
              _input(
                label: "Ảnh banner (URL)",
                controller: _bannerC,
              ),
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
              _input(
                label: "Ngân sách (đ)",
                controller: _budgetC,
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "Kích hoạt",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 12),
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
      padding: const EdgeInsets.only(bottom: 8),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
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
      ),
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final payload = {
      "title": _titleC.text.trim(),
      "description": _descC.text.trim(),
      "banner_url": _bannerC.text.trim(),
      "budget": double.tryParse(_budgetC.text) ?? 0,
      "start_date": _startDate,
      "end_date": _endDate,
      "is_active": _isActive,
    };

    final storeP = Provider.of<StoreProvider>(context, listen: false);
    final isEdit = widget.campaign != null;
    bool ok = false;
    if (isEdit) {
      ok = await storeP.updateStoreCampaign(widget.campaign!.id, payload);
    } else {
      ok = await storeP.createStoreCampaign(payload);
    }

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lưu chiến dịch thất bại")),
      );
    }
  }
}
