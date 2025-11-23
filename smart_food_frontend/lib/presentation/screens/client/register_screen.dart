import 'package:flutter/material.dart';
import 'package:smart_food_frontend/data/services/auth_service.dart';
import 'package:smart_food_frontend/presentation/routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _pwVisible = false;
  bool _confirmVisible = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFFFB347), width: 1),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFFFB347), width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
      );

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showMessage("Vui lòng nhập đầy đủ thông tin!");
      return;
    }

    if (password != confirm) {
      _showMessage("Mật khẩu không trùng khớp!");
      return;
    }

    setState(() => _isLoading = true);

    final response = await _authService.register(
      email: email,
      username: email.split('@')[0],
      password: password,
      password2: confirm,
      fullName: name,
    );

    setState(() => _isLoading = false);

    if (response != null && response["error"] == null) {
      _showMessage("Đăng ký thành công!", success: true);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      _showMessage("Lỗi: ${response?["error"]}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFB347),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Text(
                'Đăng ký',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF6EC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),

                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text('Họ và tên'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameController,
                        decoration: _inputDeco('Nhập họ và tên'),
                      ),
                      const SizedBox(height: 18),

                      const Text('Email'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        decoration: _inputDeco('Nhập email'),
                      ),
                      const SizedBox(height: 18),

                      const Text('Mật khẩu'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_pwVisible,
                        decoration: _inputDeco('Nhập mật khẩu').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _pwVisible ? Icons.visibility : Icons.visibility_off
                            ),
                            onPressed: () => setState(() => _pwVisible = !_pwVisible),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      const Text('Xác nhận mật khẩu'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _confirmController,
                        obscureText: !_confirmVisible,
                        decoration: _inputDeco('Nhập lại mật khẩu').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _confirmVisible ? Icons.visibility : Icons.visibility_off
                            ),
                            onPressed: () => setState(() => _confirmVisible = !_confirmVisible),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E613D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Đăng ký',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Nếu bạn đã có tài khoản? '),
                            TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.login,
                              ),
                              child: const Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  color: Color(0xFFFF914D),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
