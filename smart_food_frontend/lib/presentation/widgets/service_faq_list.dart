import 'package:flutter/material.dart';

class ServiceFaqList extends StatelessWidget {
  const ServiceFaqList({super.key});

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
        Text('Quản lý thẻ thanh toán', style: itemStyle),
        SizedBox(height: 10),
        Text(
          'Tại sao tôi nhận được thông báo khoản thanh toán '
              'đang được giam giữ trước khi dịch vụ hoàn tất',
          style: itemStyle,
        ),
        SizedBox(height: 10),
        Text('Về Pushan cho Doanh nghiệp', style: itemStyle),
        SizedBox(height: 28),
      ],
    );
  }
}