import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/services/merchant_storage.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/presentation/widgets/item_profile.dart'
    as item_profile;
import 'package:smart_food_frontend/providers/auth_provider.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';
import 'package:smart_food_frontend/providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.logout();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã đăng xuất")),
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFFFFF6EC),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Bạn chắc chắn chứ?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFB6D3A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE9D6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                        child: Text(
                          "Hủy",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _logout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFB6D3A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                        child: Text(
                          "Đăng xuất",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    final fullName = user?.fullName ?? user?.username ?? "User";
    final email = user?.email ?? "unknown@gmail.com";

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 80, bottom: 30, left: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFFFB347),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 33,
                  backgroundImage: (user?.avatar != null &&
                          (user?.avatar?.isNotEmpty ?? false))
                      ? NetworkImage(user!.avatar!)
                      : const AssetImage("./assets/images/default_avatar.png")
                          as ImageProvider,
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.profileDetail),
                    child: const item_profile.MenuItemWidget(
                      label: "Hồ sơ cá nhân",
                      icon: Icons.person_outline,
                      iconColor: Color(0xFFFB6D3A),
                    ),
                  ),
                  InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.voucherWallet),
                    child: const item_profile.MenuItemWidget(
                      label: "Ví voucher",
                      icon: Icons.card_giftcard_outlined,
                      iconColor: Color(0xFF2AE1E1),
                    ),
                  ),
                  InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.address),
                    child: const item_profile.MenuItemWidget(
                      label: "Địa chỉ",
                      icon: Icons.location_on_outlined,
                      iconColor: Color(0xFF36C12C),
                    ),
                  ),
                  InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.payment),
                    child: const item_profile.MenuItemWidget(
                      label: "Phương thức thanh toán",
                      icon: Icons.payment_outlined,
                      iconColor: Color(0xFFFCAE41),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final storeProvider =
                          Provider.of<StoreProvider>(context, listen: false);
                      await storeProvider.loadMyStore();
                      if (storeProvider.myStore == null) {
                        if (!context.mounted) return;
                        Navigator.pushNamed(context, AppRoutes.onStepZero);
                      } else {
                        final store = storeProvider.myStore;
                        if (store?.status == 1) {
                          if (!context.mounted) return;
                          Navigator.pushNamed(
                              context, AppRoutes.merchantPending);
                        }
                        if (store?.status == 2) {
                          final seen =
                              await MerchantStorage.isWelcomeSeen(user!.id);
                          if (!seen) {
                            if (!context.mounted) return;
                            Navigator.pushNamed(
                                context, AppRoutes.merchantStart);
                            return;
                          }
                          if (!context.mounted) return;
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.mainMerchant);
                        }
                      }
                    },
                    child: const item_profile.MenuItemWidget(
                      label: "Dành cho doanh nghiệp",
                      icon: Icons.storefront_outlined,
                      iconColor: Color(0xFFFB4A59),
                    ),
                  ),
                  const item_profile.MenuItemWidget(
                    label: "Dành cho tài xế",
                    icon: Icons.motorcycle_outlined,
                    iconColor: Color(0xFFF06A03),
                  ),
                  InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.contactSupport),
                    child: const item_profile.MenuItemWidget(
                      label: "Liên hệ hỗ trợ",
                      icon: Icons.support_agent_outlined,
                      iconColor: Color(0xFF386642),
                    ),
                  ),
                  InkWell(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.helpCenter),
                    child: const item_profile.MenuItemWidget(
                      label: "Trung tâm trợ giúp",
                      icon: Icons.help_outline,
                      iconColor: Color(0xFF3A86FF),
                    ),
                  ),
                  InkWell(
                    onTap: () => _showLogoutConfirm(context),
                    child: const item_profile.MenuItemWidget(
                      label: "Đăng xuất",
                      icon: Icons.logout,
                      iconColor: Color(0xFFB33DFB),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
