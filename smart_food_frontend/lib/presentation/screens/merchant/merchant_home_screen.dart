import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';

class MerchantHomeScreen extends StatefulWidget {
  const MerchantHomeScreen({super.key});

  @override
  State<MerchantHomeScreen> createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends State<MerchantHomeScreen> {
  bool _toggleLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final sp = Provider.of<StoreProvider>(context, listen: false);
      await sp.loadMyStore();
      await sp.loadStoreCampaigns();
      await sp.loadStoreVouchers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final store = storeProvider.myStore;
    final campaigns = storeProvider.campaigns;
    final vouchers = storeProvider.storeVouchers;
    final activeCampaigns = campaigns.where((c) => c.isActive).length;
    final activeVouchers = vouchers.where((v) => v.isActive).length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 6),
                  const Icon(Icons.location_on,
                      size: 28, color: Color(0xFF391713)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      store?.address ?? 'Chưa có địa chỉ',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF391713),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.notifications_none, size: 28),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Trạng thái cửa hàng",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF391713),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (store?.status == 4) ? "Đang đóng cửa" : "Đang mở cửa",
                          style: TextStyle(
                            color: (store?.status == 4)
                                ? Colors.red
                                : const Color(0xFF2C6B2F),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Switch.adaptive(
                      value: store?.status != 4,
                      activeColor: const Color(0xFF2C6B2F),
                      onChanged: _toggleLoading
                          ? null
                          : (_) => _toggleStoreStatus(store?.id),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Hiệu suất bán hàng",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF391713),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6F9C6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.campaign,
                                  size: 16, color: Color(0xFF2C6B2F)),
                              SizedBox(width: 6),
                              Text(
                                "Chiến dịch",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF2C6B2F),
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Đang chạy",
                            style: TextStyle(
                              color: Color(0xFF2C6B2F),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$activeCampaigns chiến dịch",
                            style: const TextStyle(
                              color: Color(0xFF2C6B2F),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC8C8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.local_offer,
                                  size: 16, color: Color(0xFF9A1B1D)),
                              SizedBox(width: 6),
                              Text(
                                "Voucher",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9A1B1D),
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Đang bật",
                            style: TextStyle(
                              color: Color(0xFF9A1B1D),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$activeVouchers voucher",
                            style: const TextStyle(
                              color: Color(0xFF9A1B1D),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                "Quản lý cửa hàng",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF391713),
                ),
              ),

              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _MenuItem(
                    icon: Icons.receipt_long,
                    label: "Đơn hàng",
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.star_border,
                    label: "Phản hồi",
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.group,
                    label: "Nhân viên",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.employeeManage);
                    },
                  ),
                  _MenuItem(
                    icon: Icons.store_mall_directory,
                    label: "Cửa hàng",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.storeInfo);
                    },
                  ),
                  _MenuItem(
                    icon: Icons.campaign,
                    label: "Quảng cáo",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.storeCampaigns);
                    },
                  ),
                  _MenuItem(
                    icon: Icons.card_giftcard,
                    label: "Mã giảm giá",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.storeVouchers);
                    },
                  ),
                  _MenuItem(
                    icon: Icons.bar_chart,
                    label: "Thống kê",
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                "Tiếp thị",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF391713),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8CC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          activeCampaigns.toString(),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF391713),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        "Chiến dịch đang diễn ra",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF391713),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "./assets/images/marketing.png",
                      width: 80,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Tạo chiến dịch tiếp thị ngay hôm nay",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF391713),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Điều khoản",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF391713),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.termsPersonal);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Image.asset(
                              "./assets/images/policy1.png",
                              height: 100,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Đối với đối tác cá nhân kinh doanh",
                              style: TextStyle(fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.termsBusiness);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Image.asset(
                              "./assets/images/policy2.png",
                              height: 100,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Đối với doanh nghiệp kinh doanh",
                              style: TextStyle(fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleStoreStatus(int? storeId) async {
    if (storeId == null) return;
    setState(() => _toggleLoading = true);
    await Provider.of<StoreProvider>(context, listen: false)
        .toggleStore(storeId);
    setState(() => _toggleLoading = false);
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: const Color(0xFF391713)),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF391713),
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
