import 'package:flutter/material.dart';

class ShipperSupportScreen extends StatelessWidget {
  const ShipperSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF9F1E6);
    const green = Color(0xFF1F7A52);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F7A52)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Hỗ trợ & giải đáp",
          style: TextStyle(
            color: Color(0xFF1F7A52),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _banner(green),
            const SizedBox(height: 16),
            _faqList(),
            const SizedBox(height: 20),
            _contactBox(),
          ],
        ),
      ),
    );
  }

  Widget _banner(Color green) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.support_agent, color: Color(0xFF1F7A52)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chúng tôi luôn sẵn sàng hỗ trợ",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Xem câu hỏi thường gặp hoặc liên hệ trực tiếp để được trợ giúp nhanh.",
                  style: TextStyle(color: Colors.black54, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqList() {
    final faqs = [
      {
        "q": "Tôi không nhận được đơn?",
        "a": "Hãy kiểm tra trạng thái nhận đơn và đảm bảo ứng dụng đã bật định vị."
      },
      {
        "q": "Làm sao để rút tiền?",
        "a": "Vào Ví & giao dịch, chọn Rút tiền, nhập số tiền và xác nhận."
      },
      {
        "q": "Tôi muốn cập nhật thông tin ngân hàng?",
        "a": "Vào Ví & giao dịch > Phương thức thanh toán để đổi tài khoản."
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Câu hỏi thường gặp",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        ...faqs.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["q"] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item["a"] as String,
                  style: const TextStyle(
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _contactBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Liên hệ",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.phone, color: Color(0xFF1F7A52)),
              SizedBox(width: 8),
              Text("Hotline: 1900 1234"),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: const [
              Icon(Icons.email_outlined, color: Color(0xFF1F7A52)),
              SizedBox(width: 8),
              Text("Email: support@pushanfood.vn"),
            ],
          ),
        ],
      ),
    );
  }
}
