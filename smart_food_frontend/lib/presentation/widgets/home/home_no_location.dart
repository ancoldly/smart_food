import 'package:flutter/material.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/address_provider.dart';
import 'package:smart_food_frontend/providers/user_provider.dart';
import 'package:provider/provider.dart';

class HomeNoLocation extends StatelessWidget {
  final Future<void> Function(Map data) onSaveAddress;
  const HomeNoLocation({super.key, required this.onSaveAddress});

  Future<void> _quickAddAddressByMap(BuildContext context) async {
    final result =
        await Navigator.pushNamed(context, AppRoutes.selectLocation);
    if (result is Map) {
      await onSaveAddress(result);
    }
  }

  Future<void> _gotoAddAddress(BuildContext context) async {
    await Navigator.pushNamed(context, AppRoutes.addAddress);
    if (context.mounted) {
      await Provider.of<AddressProvider>(context, listen: false)
          .loadAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 48, color: Colors.orange),
            const SizedBox(height: 12),
            const Text(
              "Chưa có vị trí",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              "Vui lòng thêm địa chỉ hoặc chọn vị trí trên bản đồ để xem các quán gần bạn.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _quickAddAddressByMap(context),
              child: const Text("Thêm nhanh"),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => _gotoAddAddress(context),
              child: const Text("Thêm địa chỉ"),
            ),
          ],
        ),
      ),
    );
  }
}
