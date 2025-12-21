import 'package:flutter/material.dart';
import 'package:smart_food_frontend/presentation/screens/merchant/on_step_two_screen.dart';
import 'package:smart_food_frontend/presentation/widgets/service_card_on_step_one.dart';

class OnStepOneScreen extends StatelessWidget {
  const OnStepOneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF6ECE3);
    const lineColor = Color(0xFF546F41);
    const green = Color(0xFF255B36);
    const textDark = Color(0xFF222222);

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
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios,
                  size: 18, color: Colors.black87),
            ),
            const SizedBox(width: 4),
            const Text(
              'Bước 1 trên 2',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.help_outline, color: green, size: 22),
            ),
            const SizedBox(width: 6),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: lineColor),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Vui lòng chọn 1 dịch vụ",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Chọn dịch vụ phù hợp để bắt đầu khởi tạo hoạt động kinh doanh của bạn.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 30),
              ServiceCard(
                imagePath: "./assets/images/pushan_food.png",
                title: "Pushan Food",
                description:
                    "Dịch vụ giao đồ ăn và thức uống đã được chế biến sẵn tới tận tay người dùng",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnStepTwoScreen(
                        category: "food",
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ServiceCard(
                imagePath: "./assets/images/pushan_mart.png",
                title: "Pushan Mart",
                description:
                    "Dịch vụ giao các mặt hàng thực phẩm tươi sống, đồ khô, rau củ quả, hàng tiêu dùng và các sản phẩm gia dụng...",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnStepTwoScreen(
                        category: "mart",
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
