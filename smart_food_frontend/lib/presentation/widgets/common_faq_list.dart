import 'package:flutter/material.dart';
class CommonFaqList extends StatelessWidget {
  const CommonFaqList({super.key});

  @override
  Widget build(BuildContext context) {
    const itemStyle = TextStyle(
      fontSize: 14,
      height: 1.45,
      color: Colors.black87,
    );

    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4),
        Text(
          'Ứng dụng không hoạt động hoặc đang gặp sự cố',
          style: itemStyle,
        ),
        SizedBox(height: 10),
        Text(
          'Hướng dẫn đầy đủ về xác thực email cho tài khoản Pushan của bạn',
          style: itemStyle,
        ),
        SizedBox(height: 10),
        Text(
          'Tôi cần liên kết hoặc gỡ liên kết tài khoản Pushan '
              'với tài khoản Facebook/Google',
          style: itemStyle,
        ),
        SizedBox(height: 28),
      ],
    );
  }
}