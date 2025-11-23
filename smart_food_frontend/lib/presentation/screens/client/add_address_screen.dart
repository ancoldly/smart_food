import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/providers/address_provider.dart';
import 'package:smart_food_frontend/presentation/screens/client/select_location_screen.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final wardCtrl = TextEditingController();
  final streetCtrl = TextEditingController();

  double? lat;
  double? lng;

  bool isDefault = false;
  String selectedType = "Nhà riêng";
  bool isLoading = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    wardCtrl.dispose();
    streetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Thêm địa chỉ mới",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF5B7B56)),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
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
                  _input("Số điện thoại", phoneCtrl,
                      type: TextInputType.phone),
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
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
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
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Đặt làm địa chỉ mặc định",
                        style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF5B3A1E),
                            fontWeight: FontWeight.w600),
                      ),
                      Switch(
                        value: isDefault,
                        activeColor: const Color(0xFF5B7B56),
                        onChanged: (v) =>
                            setState(() => isDefault = v),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  const Text(
                    "Loại địa chỉ",
                    style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF5B3A1E),
                        fontWeight: FontWeight.w600),
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
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B7B56),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Hoàn thành",
                        style: TextStyle(
                            color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
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
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: active
                  ? const Color(0xFF5B7B56)
                  : const Color(0xFFB8B8B8)),
          color:
              active ? const Color(0xFFEEF5EE) : Colors.white,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active
                ? const Color(0xFF5B7B56)
                : const Color(0xFF5B3A1E),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _openMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const SelectLocationScreen()),
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

  Future<void> _submit() async {
    if (nameCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        wardCtrl.text.isEmpty ||
        streetCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")));
      return;
    }

    setState(() => isLoading = true);

    final provider =
        Provider.of<AddressProvider>(context, listen: false);

    final success = await provider.addAddress({
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

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thêm địa chỉ thành công")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thêm địa chỉ thất bại")));
    }
  }
}
