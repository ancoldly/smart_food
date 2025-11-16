import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_food_frontend/providers/user_provider.dart';

void showChangePasswordSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ChangePasswordSheet(),
  );
}

void showTopNotification(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(const Duration(seconds: 2)).then((_) {
    overlayEntry.remove();
  });
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final TextEditingController oldPass = TextEditingController();
  final TextEditingController newPass = TextEditingController();
  final TextEditingController confirmPass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.48,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF6EC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),

          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              controller: controller,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Hủy",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Text(
                        "Thay đổi mật khẩu",
                        style: TextStyle(
                          color: Color(0xFF5B7B56),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final oldP = oldPass.text.trim();
                          final newP = newPass.text.trim();
                          final confirmP = confirmPass.text.trim();

                          if (oldP.isEmpty || newP.isEmpty || confirmP.isEmpty) {
                            showTopNotification(context,
                                "Vui lòng nhập đầy đủ thông tin");
                            return;
                          }

                          if (newP != confirmP) {
                            showTopNotification(context,
                                "Xác nhận mật khẩu không trùng khớp");
                            return;
                          }

                          final userProvider =
                              Provider.of<UserProvider>(context, listen: false);
                          final result = await userProvider.changePassword(
                            oldPassword: oldP,
                            newPassword: newP,
                            confirmPassword: confirmP,
                          );

                          if (!mounted) return;

                          if (result["success"] == true) {
                            Navigator.pop(context);
                            await Future.delayed(
                                const Duration(milliseconds: 80));

                            // ignore: use_build_context_synchronously
                            showTopNotification(
                                context, "Đổi mật khẩu thành công");
                          } else {
                            showTopNotification(
                                context,
                                result["message"] ??
                                    "Đổi mật khẩu thất bại");
                          }
                        },
                        child: const Text(
                          "Thay đổi",
                          style: TextStyle(
                            color: Color(0xFF5B7B56),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      children: [
                        _PasswordRow(
                          label: "Mật khẩu cũ",
                          hint: "Nhập mật khẩu cũ",
                          controller: oldPass,
                        ),
                        const Divider(height: 1),
                        _PasswordRow(
                          label: "Mật khẩu mới",
                          hint: "Nhập mật khẩu mới",
                          controller: newPass,
                        ),
                        const Divider(height: 1),
                        _PasswordRow(
                          label: "Xác nhận",
                          hint: "Xác nhận mật khẩu",
                          controller: confirmPass,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PasswordRow extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _PasswordRow({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF5B7B56),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.black38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
