import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/data/services/merchant_storage.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';
import 'package:smart_food_frontend/providers/user_provider.dart';

class MerchantStartScreen extends StatefulWidget {
  const MerchantStartScreen({super.key});

  @override
  State<MerchantStartScreen> createState() => _MerchantStartScreenState();
}

class _MerchantStartScreenState extends State<MerchantStartScreen> {
  bool _agree = true;

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFFFB347);
    const greenColor = Color(0xFF285943);
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("./assets/images/logo.png",
                            width: 50, height: 50),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pushan",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: greenColor,
                              ),
                            ),
                            Text(
                              "Merchant",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: greenColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "Chào mừng bạn đã gia\nnhập Pushan!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: greenColor,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 220,
                      child: Image.asset(
                        "./assets/images/merchant_welcome.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      "Chúng tôi rất vui khi bạn đã gia nhập hệ thống đối tác.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xFF3D2614),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Từ bây giờ, bạn có thể quản lý cửa hàng, theo dõi đơn hàng và nhận hỗ trợ nhanh chóng từ đội ngũ Pushan.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        color: Color(0xFF3D2614),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agree,
                          onChanged: (v) {
                            setState(() {
                              _agree = v ?? false;
                            });
                          },
                          activeColor: greenColor,
                          checkColor: Colors.white,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12.5,
                                height: 1.4,
                                color: Color(0xFF3D2614),
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      "Bằng cách tiếp tục sử dụng ứng dụng Pushan, bạn xác nhận rằng mình đã đọc và đồng ý với ",
                                ),
                                TextSpan(
                                  text:
                                      "Điều khoản dịch vụ & Chính sách bảo mật",
                                  style: const TextStyle(
                                    color: Color(0xFF00796B),
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                ),
                                const TextSpan(text: "."),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _agree
                          ? () async {
                              final userId = Provider.of<UserProvider>(context,
                                      listen: false)
                                  .user!
                                  .id;
                              await MerchantStorage.setWelcomeSeen(userId);

                              // ignore: use_build_context_synchronously
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.mainMerchant);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _agree ? greenColor : greenColor.withOpacity(0.5),
                        disabledBackgroundColor: greenColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        "Bắt đầu kinh doanh",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
