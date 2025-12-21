import 'package:flutter/material.dart';

class TermsPersonalScreen extends StatelessWidget {
  const TermsPersonalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Điều khoản cho cá nhân kinh doanh",
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
                "Điều khoản dành cho đối tác cá nhân kinh doanh",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF391713),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                """
1. Quy định chung  
- Đối tác cá nhân phải đảm bảo thông tin cung cấp là chính xác.  
- Mọi hoạt động kinh doanh phải tuân thủ quy định pháp luật.  

2. Trách nhiệm của đối tác  
- Đảm bảo chất lượng món ăn, vệ sinh an toàn thực phẩm.  
- Phản hồi nhanh chóng các đơn hàng từ hệ thống.  
- Cập nhật thông tin cửa hàng chính xác.  

3. Thanh toán  
- Doanh thu sẽ được tổng hợp và thanh toán theo kỳ.  
- Phí dịch vụ được tính dựa trên tỷ lệ phần trăm thỏa thuận.  

4. Chấm dứt hợp tác  
- Hai bên có quyền ngưng hợp tác với thông báo trước 7 ngày.
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
