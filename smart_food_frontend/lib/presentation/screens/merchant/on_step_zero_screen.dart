import 'package:flutter/material.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/presentation/widgets/info_row_start.dart';

class OnStepZeroScreen extends StatelessWidget {
  const OnStepZeroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF6ECE3); 
    const primaryGreen = Color(0xFF255B36); 
    const textDark = Color(0xFF222222);
    const textBody = Color(0xFF555555);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'Merchant Pushan Food',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFF546F41), 
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tiếp cận nhiều khách hàng\nhơn với Pushan',
                style: TextStyle(
                  fontSize: 24,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Vui lòng hoàn tất các bước sau để bắt đầu kinh '
                'doanh với Pushan',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: textBody,
                ),
              ),
              const SizedBox(height: 30),

              const InfoRow(
                iconBackground: Color(0xFFFFF0D7),
                iconBorder: Color(0xFFCB7D3A),
                icon: Icons.store_mall_directory_outlined,
                title: 'Mô tả hoạt động kinh doanh của bạn',
                description:
                    'Cung cấp đầy đủ các thông tin yêu cầu về bạn và hoạt '
                    'động kinh doanh của bạn',
              ),
              const SizedBox(height: 26),
              const InfoRow(
                iconBackground: Color(0xFFFFF0D7),
                iconBorder: Color(0xFFCB7D3A),
                icon: Icons.restaurant_menu_rounded,
                title: 'Thiết lập cửa hàng trên Pushan',
                description:
                    'Quản lý giao diện cửa hàng trên ứng dụng Pushan: Bạn '
                    'có thể tải lên ảnh đại diện, ảnh bìa, tạo thực đơn cho '
                    'cửa hàng và nhiều thứ hơn thế nữa. Hãy thiết lập cửa '
                    'hàng trông thật nổi bật theo cách của bạn!',
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.onStepOne);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tiếp tục',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.5,
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
      ),
    );
  }
}
