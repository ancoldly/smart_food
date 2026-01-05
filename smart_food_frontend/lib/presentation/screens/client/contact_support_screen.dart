import 'package:flutter/material.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6EC),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF5B7B56)),
        ),
        title: const Text(
          "Liên hệ hỗ trợ",
          style: TextStyle(
            color: Color(0xFF5B7B56),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB347).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.support_agent,
                            color: Color(0xFFFF7043)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Bạn cần hỗ trợ gì?\nChúng tôi sẵn sàng giúp bạn 24/7.",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3C2F2F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Chọn một kênh bên dưới để liên hệ nhanh.",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            _contactTile(
              context,
              icon: Icons.chat_bubble_outline,
              title: "Chat trực tuyến",
              subtitle: "Phản hồi trong vài phút",
              color: const Color(0xFF3E613D),
              onTap: () {},
            ),
            _contactTile(
              context,
              icon: Icons.phone_in_talk_outlined,
              title: "Gọi hotline",
              subtitle: "1900 636 736 (8h - 22h)",
              color: const Color(0xFFFB6D3A),
              onTap: () {},
            ),
            _contactTile(
              context,
              icon: Icons.email_outlined,
              title: "Gửi email",
              subtitle: "support@smartfood.com",
              color: const Color(0xFF3A86FF),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Câu hỏi thường gặp",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3C2F2F),
                    ),
                  ),
                  SizedBox(height: 12),
                  _FaqItem(
                    question: "Làm sao đổi mật khẩu?",
                    answer:
                        "Vào Hồ sơ > Đổi mật khẩu, nhập mật khẩu hiện tại và mật khẩu mới.",
                  ),
                  SizedBox(height: 10),
                  _FaqItem(
                    question: "Tôi muốn cập nhật địa chỉ giao hàng?",
                    answer:
                        "Vào Hồ sơ > Địa chỉ, thêm hoặc sửa địa chỉ mặc định của bạn.",
                  ),
                  SizedBox(height: 10),
                  _FaqItem(
                    question: "Thanh toán không thành công?",
                    answer:
                        "Kiểm tra kết nối internet, hạn mức thẻ, hoặc thử phương thức khác. Nếu vẫn lỗi, liên hệ hotline.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF3C2F2F),
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF3C2F2F),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}
