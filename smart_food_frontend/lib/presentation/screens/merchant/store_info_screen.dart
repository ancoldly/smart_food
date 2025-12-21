import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/store_provider.dart';
import 'package:smart_food_frontend/data/models/store_operating_hour_model.dart';

class StoreInfoScreen extends StatefulWidget {
  const StoreInfoScreen({super.key});

  @override
  State<StoreInfoScreen> createState() => _StoreInfoScreenState();
}

class _StoreInfoScreenState extends State<StoreInfoScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<StoreProvider>(context, listen: false).loadMyStore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final store = storeProvider.myStore;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),

      // =======================
      //        APPBAR
      // =======================
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Cửa hàng",
          style: TextStyle(
            color: Color(0xFF391713),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF391713)),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =======================
            //  COMPLETE INFO BANNER
            // =======================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDFF5D2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF89C270)),
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F3D7),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text(
                      "90%",
                      style: TextStyle(
                        color: Color(0xFF2C6B2F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "Hoàn tất thêm thông tin quán để giúp khách hàng dễ tìm kiếm hơn.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2C6B2F),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =======================
            // STORE NAME + SUBTITLE
            // =======================
            Text(
              store?.storeName ?? "Unknown Store",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF391713),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (store?.category ?? "").toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 212, 80, 32),
              ),
            ),

            const SizedBox(height: 20),

            // =======================
            //   IMAGE SECTIONS
            // =======================
            _ImageCard(
              title: "Ảnh quán",
              description:
                  "Đây là ảnh sẽ hiển thị lên đầu trang menu của quán bạn",
              imageUrl: store?.backgroundImage ?? "",
            ),
            const SizedBox(height: 14),
            _ImageCard(
              title: "Hình ảnh hiển thị",
              description:
                  "Đây là ảnh dùng để hiển thị khi cửa hàng của bạn được xuất hiện cùng với các doanh nghiệp khác",
              imageUrl: store?.backgroundImage ?? "",
            ),

            const SizedBox(height: 24),

            // =======================
            //      SETTINGS LISTS
            // =======================
            _SettingItem(
              title: "Phân loại kinh doanh",
              icon: Icons.fastfood_outlined,
              onTap: () => Navigator.pushNamed(context, AppRoutes.storeTags),
            ),
            _SettingItem(
              title: "Giờ hoạt động",
              subtitleLeft: "Thời gian mở cửa",
              subtitleRight: _formatOperatingHours(store?.operatingHours),
              icon: Icons.access_time,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.storeOperatingHours,
              ).then((_) {
                Provider.of<StoreProvider>(context, listen: false)
                    .loadMyStore();
              }),
            ),
            _SettingItem(
              title: "Thông tin liên hệ của chủ / quản lý quán",
              icon: Icons.mail_outline,
              bottomText: "${store?.managerPhone}\n${store?.managerEmail}",
            ),
            _SettingItem(
              title: "Số điện thoại của quán",
              icon: Icons.phone_outlined,
              bottomText: store?.managerPhone ?? "",
            ),
            _SettingItem(
              title: "Địa chỉ quán",
              icon: Icons.location_on_outlined,
              bottomText: store?.address ?? "",
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                   Navigator.pushNamed(
                          context,
                          AppRoutes.editStore,
                          arguments: store?.id,
                        ).then((_) {
                          Provider.of<StoreProvider>(context, listen: false)
                              .loadMyStore();
                        });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF255B36),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text(
                  "Chỉnh sửa thông tin",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFBEFD8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatOperatingHours(List<StoreOperatingHourModel>? hours) {
    if (hours == null || hours.isEmpty) return "Chưa thiết lập";
    final firstOpen = hours.firstWhere(
      (h) => !h.isClosed,
      orElse: () => StoreOperatingHourModel(
        id: -1,
        dayOfWeek: 0,
        openTime: null,
        closeTime: null,
        isClosed: true,
      ),
    );
    if (firstOpen == null) return "Đang đóng cửa";
    if (firstOpen.isClosed) return "Đang đóng cửa";
    final open = firstOpen.openTime ?? "--:--";
    final close = firstOpen.closeTime ?? "--:--";
    return "$open - $close";
  }
}

//
// ============================================
// IMAGE CARD
// ============================================
class _ImageCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const _ImageCard({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECEC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFB71C1C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover, // QUAN TRỌNG
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF391713),
                    )),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6D4C41),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF6D4C41)),
        ],
      ),
    );
  }
}

//
// ============================================
// SETTING ITEM
// ============================================
class _SettingItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitleLeft;
  final String? subtitleRight;
  final String? bottomText;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.title,
    required this.icon,
    this.subtitleLeft,
    this.subtitleRight,
    this.bottomText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF391713)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF391713),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF6D4C41)),
              ],
            ),

            // Subtitles (optional)
            if (subtitleLeft != null || subtitleRight != null) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    subtitleLeft ?? "",
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  Text(
                    subtitleRight ?? "",
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF391713),
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],

            // Bottom text (optional)
            if (bottomText != null) ...[
              const SizedBox(height: 10),
              Text(
                bottomText!,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.black87,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
