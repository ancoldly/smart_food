import 'package:flutter/material.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';

class ShipperPendingScreen extends StatelessWidget {
  const ShipperPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF255B36);
    const bg = Color(0xFFF6ECE3);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Trạng thái tài xế",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_top_rounded, size: 100, color: green),
              const SizedBox(height: 20),
              const Text(
                "Yêu cầu của bạn đang được duyệt",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Thông tin tài xế của bạn đã gửi thành công. "
                "Pushan sẽ kiểm tra và phản hồi trong thời gian sớm nhất.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.popAndPushNamed(
                    context,
                    AppRoutes.main,
                    arguments: 3,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text(
                    "Quay lại",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
