import 'package:flutter/material.dart';

class TermsBusinessScreen extends StatelessWidget {
  const TermsBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Điều khoản cho doanh nghiệp",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Điều khoản dành cho các doanh nghiệp kinh doanh",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF391713),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                """
1. Quy định pháp lý  
- Doanh nghiệp phải cung cấp đầy đủ giấy phép kinh doanh.  
- Thông tin thuế, mã số doanh nghiệp phải đúng với pháp luật Việt Nam.  

2. Quyền và nghĩa vụ của doanh nghiệp  
- Cam kết bảo mật dữ liệu khách hàng.  
- Đảm bảo quy trình chế biến, bảo quản thực phẩm đúng tiêu chuẩn.  
- Có trách nhiệm xử lý khiếu nại liên quan đến chất lượng sản phẩm.  

3. Chính sách chiết khấu & phí dịch vụ  
- Phí hoa hồng được tính theo hợp đồng đã ký.  
- Các khoản phí phát sinh thêm sẽ được thông báo rõ ràng trước khi áp dụng.  

4. Chấm dứt hợp tác  
- Quy trình chấm dứt căn cứ theo hợp đồng đã ký giữa hai bên.
                """,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF391713),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
