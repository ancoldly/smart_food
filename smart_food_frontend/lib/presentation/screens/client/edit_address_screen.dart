import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_food_frontend/data/models/address_model.dart';
import 'package:smart_food_frontend/providers/address_provider.dart';
import 'package:smart_food_frontend/presentation/screens/client/select_location_screen.dart';

class EditAddressScreen extends StatefulWidget {
  final AddressModel address;
  const EditAddressScreen({super.key, required this.address});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController wardCtrl;
  late TextEditingController streetCtrl;

  double? lat;
  double? lng;

  bool isDefault = false;
  String selectedType = "Nhà riêng";
  bool isLoading = false;
  bool deleting = false;

  @override
  void initState() {
    super.initState();

    final parts = widget.address.addressLine.split(",");
    final street = parts.isNotEmpty ? parts.first.trim() : "";
    final ward = parts.length > 1 ? parts.sublist(1).join(",").trim() : "";

    nameCtrl = TextEditingController(text: widget.address.receiverName);
    phoneCtrl = TextEditingController(text: widget.address.receiverPhone);
    streetCtrl = TextEditingController(text: street);
    wardCtrl = TextEditingController(text: ward);

    selectedType = widget.address.label;
    isDefault = widget.address.isDefault;

    lat = widget.address.latitude;
    lng = widget.address.longitude;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF5B7B56)),
        ),
        title: const Text(
          "Chỉnh sửa địa chỉ",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: deleting ? null : _confirmDelete,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _buildInputCard(),
            const SizedBox(height: 18),
            _buildSettingCard(),
            const SizedBox(height: 50),
            _buildSubmitButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Địa chỉ",
              style: TextStyle(
                color: Color(0xFF5B3A1E),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              )),

          const SizedBox(height: 12),

          _input("Họ và tên", nameCtrl),
          _input("Số điện thoại", phoneCtrl, type: TextInputType.phone),
          _input("Phường/xã, Quận/Huyện, Tỉnh", wardCtrl),
          _input("Số nhà, tên đường", streetCtrl),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _openMap,
              icon: const Icon(Icons.location_on_outlined,
                  color: Color(0xFF5B7B56)),
              label: const Text(
                "Chọn trên bản đồ",
                style: TextStyle(
                  color: Color(0xFF5B7B56),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          if (lat != null)
            Text("Vị trí: ($lat, $lng)",
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildSettingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Đặt làm địa chỉ mặc định",
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF5B3A1E),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: isDefault,
                activeColor: const Color(0xFF5B7B56),
                onChanged: (value) => setState(() => isDefault = value),
              ),
            ],
          ),

          const Divider(height: 24),

          const Text(
            "Loại địa chỉ",
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF5B3A1E),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _typeButton("Nhà riêng"),
              const SizedBox(width: 10),
              _typeButton("Văn phòng"),
              const SizedBox(width: 10),
              _typeButton("Khác"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _updateAddress,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B7B56),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Xác nhận",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _input(String hint, TextEditingController ctrl,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black12),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black45),
          ),
        ),
      ),
    );
  }

  Widget _typeButton(String text) {
    final active = selectedType == text;

    return GestureDetector(
      onTap: () => setState(() => selectedType = text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: active ? const Color(0xFF5B7B56) : const Color(0xFFB8B8B8)),
          color: active ? const Color(0xFFEEF5EE) : Colors.white,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? const Color(0xFF5B7B56) : const Color(0xFF5B3A1E),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _openMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectLocationScreen()),
    );

    if (result != null) {
      setState(() {
        lat = result["lat"];
        lng = result["lng"];
        streetCtrl.text = result["street"] ?? "";
        wardCtrl.text = result["ward"] ?? "";
      });
    }
  }

  Future<void> _updateAddress() async {
    if (nameCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        wardCtrl.text.isEmpty ||
        streetCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    setState(() => isLoading = true);

    final provider = Provider.of<AddressProvider>(context, listen: false);

    final success = await provider.updateAddress(widget.address.id, {
      "receiver_name": nameCtrl.text.trim(),
      "receiver_phone": phoneCtrl.text.trim(),
      "address_line":
          "${streetCtrl.text.trim()}, ${wardCtrl.text.trim()}",
      "label": selectedType,
      "is_default": isDefault,
      "latitude": lat,
      "longitude": lng,
    });

    if (!mounted) return;

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Cập nhật thành công" : "Cập nhật thất bại"),
      ),
    );

    if (success) Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xóa địa chỉ?"),
        content: const Text("Bạn có chắc muốn xóa địa chỉ này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAddress();
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAddress() async {
    setState(() => deleting = true);

    final provider = Provider.of<AddressProvider>(context, listen: false);
    final success = await provider.deleteAddress(widget.address.id);

    if (!mounted) return;

    setState(() => deleting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Đã xóa địa chỉ" : "Xóa thất bại"),
      ),
    );

    if (success) Navigator.pop(context);
  }
}
