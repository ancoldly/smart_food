import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/models/address_model.dart';
import 'package:smart_food_frontend/providers/address_provider.dart';

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

  bool isDefault = false;
  String selectedType = "Nhà riêng";
  bool isLoading = false;
  bool deleting = false;

  @override
  void initState() {
    super.initState();

    final parts = widget.address.addressLine.split(","); 
    final streetPart = parts.isNotEmpty ? parts.first : "";
    final wardPart = parts.length > 1 ? parts.sublist(1).join(",").trim() : "";

    nameCtrl = TextEditingController(text: widget.address.receiverName);
    phoneCtrl = TextEditingController(text: widget.address.receiverPhone);
    streetCtrl = TextEditingController(text: streetPart);
    wardCtrl = TextEditingController(text: wardPart);

    isDefault = widget.address.isDefault;
    selectedType = widget.address.label;
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
          )
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Địa chỉ",
            style: TextStyle(
              color: Color(0xFF5B3A1E),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _input("Họ và tên", nameCtrl),
          _input("Số điện thoại", phoneCtrl),
          _input("Phường/xã, Quận/Huyện, Tỉnh/Thành phố", wardCtrl),
          _input("Tên đường, toà nhà, số nhà", streetCtrl),
        ],
      ),
    );
  }

  Widget _buildSettingCard() {
    return Container(
      padding: const EdgeInsets.all(14),
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
                onChanged: (value) {
                  setState(() => isDefault = value);
                },
              ),
            ],
          ),

          const Divider(height: 20),

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
          )
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

  Widget _input(String hint, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
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
    final isSelected = selectedType == text;

    return GestureDetector(
      onTap: () => setState(() => selectedType = text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF5B7B56) : const Color(0xFFB8B8B8),
          ),
          color: isSelected ? const Color(0xFFEEF5EE) : Colors.white,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? const Color(0xFF5B7B56) : const Color(0xFF5B3A1E),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
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

    final body = {
      "receiver_name": nameCtrl.text,
      "receiver_phone": phoneCtrl.text,
      "address_line": "${streetCtrl.text}, ${wardCtrl.text}",
      "label": selectedType,
      "is_default": isDefault,
    };

    final provider = Provider.of<AddressProvider>(context, listen: false);
    final success = await provider.updateAddress(widget.address.id, body);

    setState(() => isLoading = false);

    if (!mounted) return;

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

    setState(() => deleting = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Đã xóa địa chỉ" : "Xóa thất bại"),
      ),
    );

    if (success) Navigator.pop(context);
  }
}
