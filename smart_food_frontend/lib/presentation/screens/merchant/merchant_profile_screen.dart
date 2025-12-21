import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/auth_provider.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';

class MerchantProfileScreen extends StatelessWidget {
  const MerchantProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storeP = Provider.of<StoreProvider>(context);
    final store = storeP.myStore;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Tài khoản",
          style: TextStyle(
            color: Color(0xFF391713),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(store?.managerName ?? "Chủ cửa hàng",
                store?.managerEmail ?? ""),
            const SizedBox(height: 16),
            _sectionTitle("Thông tin quản lý"),
            _infoTile(Icons.person, "Tên quản lý",
                store?.managerName ?? "Chưa cập nhật"),
            _infoTile(
                Icons.call, "SĐT", store?.managerPhone ?? "Chưa cập nhật"),
            _infoTile(
                Icons.email, "Email", store?.managerEmail ?? "Chưa cập nhật"),
            _infoTile(Icons.store_mall_directory, "Cửa hàng",
                store?.storeName ?? "Chưa cập nhật"),
            const SizedBox(height: 20),
            _sectionTitle("Tiện ích"),
            _actionTile(
              icon: Icons.credit_card,
              title: "Phương thức thanh toán",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.payment);
              },
            ),
            _actionTile(
              icon: Icons.account_balance_wallet,
              title: "Đối soát & ví",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.settlement);
              },
            ),
            _actionTile(
              icon: Icons.support_agent,
              title: "Hỗ trợ",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.contactSupport);
              },
            ),
            const SizedBox(height: 20),
            _sectionTitle("Tài khoản"),
            _actionTile(
              icon: Icons.logout,
              title: "Đăng xuất",
              iconColor: Colors.red,
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String name, String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8CC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.store, color: Color(0xFF391713), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF391713),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email.isNotEmpty ? email : "Chưa cập nhật",
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: Color(0xFF391713),
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF391713)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF391713),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    Color iconColor = const Color(0xFF391713),
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF391713),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black45),
        onTap: onTap,
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Đăng xuất"),
        content: const Text("Bạn có chắc chắn muốn đăng xuất?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Đăng xuất",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã đăng xuất")),
        );
      }
    }
  }
}
