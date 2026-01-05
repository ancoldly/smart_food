import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/shipper_provider.dart';

class ShipperProfileEditScreen extends StatefulWidget {
  const ShipperProfileEditScreen({super.key});

  @override
  State<ShipperProfileEditScreen> createState() => _ShipperProfileEditScreenState();
}

class _ShipperProfileEditScreenState extends State<ShipperProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _vehicleCtrl = TextEditingController();
  final TextEditingController _plateCtrl = TextEditingController();
  final TextEditingController _idCtrl = TextEditingController();

  double? _lat;
  double? _lng;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final me = context.read<ShipperProvider>().me;
    _nameCtrl.text = me?["full_name"] ?? "";
    _phoneCtrl.text = me?["phone"] ?? "";
    _cityCtrl.text = me?["city"] ?? "";
    _addressCtrl.text = me?["address"] ?? "";
    _vehicleCtrl.text = me?["vehicle_type"] ?? "";
    _plateCtrl.text = me?["license_plate"] ?? "";
    _idCtrl.text = me?["id_number"] ?? "";
    _lat = (me?["latitude"] as num?)?.toDouble();
    _lng = (me?["longitude"] as num?)?.toDouble();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _addressCtrl.dispose();
    _vehicleCtrl.dispose();
    _plateCtrl.dispose();
    _idCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF9F1E6);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F7A52)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Cập nhật thông tin",
          style: TextStyle(
            color: Color(0xFF1F7A52),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFFF6EC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field("Họ tên", _nameCtrl),
              _field("Số điện thoại", _phoneCtrl, keyboardType: TextInputType.phone),
              _field("Thành phố", _cityCtrl),
              _addressTile(context),
              _field("Loại xe", _vehicleCtrl),
              _field("Biển số", _plateCtrl),
              _field("CMND/CCCD", _idCtrl),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F7A52),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Lưu",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
            validator: (v) => (v == null || v.isEmpty) ? "Không được để trống" : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressTile(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(context, AppRoutes.selectLocation);
        if (result is Map) {
          setState(() {
            _lat = (result["lat"] as num?)?.toDouble();
            _lng = (result["lng"] as num?)?.toDouble();
            _addressCtrl.text = result["address"] ?? _addressCtrl.text;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E0D7)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF1F7A52)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Địa chỉ",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    _addressCtrl.text.isEmpty ? "Chọn địa chỉ trên bản đồ" : _addressCtrl.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  if (_lat != null && _lng != null)
                    Text(
                      "($_lat, $_lng)",
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final body = {
      "full_name": _nameCtrl.text.trim(),
      "phone": _phoneCtrl.text.trim(),
      "city": _cityCtrl.text.trim(),
      "address": _addressCtrl.text.trim(),
      "vehicle_type": _vehicleCtrl.text.trim(),
      "license_plate": _plateCtrl.text.trim(),
      "id_number": _idCtrl.text.trim(),
      if (_lat != null) "latitude": _lat,
      if (_lng != null) "longitude": _lng,
    };
    final data = await context.read<ShipperProvider>().updateProfile(body);
    setState(() => _saving = false);
    if (data != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thành công")),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thất bại")),
      );
    }
  }
}
