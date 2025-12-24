import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ves_event_booking/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:ves_event_booking/providers/auth_provider.dart';
import 'package:ves_event_booking/screens/staff_screen.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onSwitch;
  final VoidCallback onForgotPasswordButton;
  const LoginForm({
    super.key,
    required this.onSwitch,
    required this.onForgotPasswordButton,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String _username = "";
  String _password = "";
  bool _rememberMe = false;
  bool _isButtonEnabled = false;

  void _validateInputs() {
    // Kiểm tra nhập liệu: không được để trống và không chỉ chứa khoảng trắng
    final isValid = _username.trim().isNotEmpty && _password.trim().isNotEmpty;

    if (_isButtonEnabled != isValid) {
      setState(() {
        _isButtonEnabled = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 60,
            height: 4,
            margin: const EdgeInsets.only(bottom: 45),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        TextField(
          decoration: InputDecoration(
            labelText: "Username",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            labelStyle: const TextStyle(fontStyle: FontStyle.italic),
          ),
          onChanged: (value) {
            setState(() {
              _username = value;
              _validateInputs();
            });
          },
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Mật khẩu",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            labelStyle: const TextStyle(fontStyle: FontStyle.italic),
          ),
          onChanged: (value) {
            setState(() {
              _password = value;
              _validateInputs();
            });
          },
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (v) {
                setState(() {
                  _rememberMe = v ?? false;
                });
              },
              activeColor: Colors.green,
            ),
            const Text("Lưu mật khẩu"),
            const Spacer(),
            TextButton(
              onPressed: widget.onForgotPasswordButton,
              child: const Text(
                "Quên mật khẩu?",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton(
            // onPressed: () {
            //   Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(builder: (context) => const HomeScreen()),
            //   );
            // },
            onPressed: (_isButtonEnabled && !authProvider.isLoading)
                ? () async {
                    String roles = await authProvider.login(
                      _username,
                      _password,
                    );

                    if (roles.isNotEmpty) {
                      if (roles == "USER") {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      } else if (roles == "STAFF") {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StaffScreen(),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            authProvider.errorMessage ?? 'Lỗi đăng nhập',
                          ),
                        ),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Đăng nhập",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Đăng nhập với",
                style: TextStyle(color: Colors.black),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),

        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
              onPressed: () async {},
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
              onPressed: () {},
            ),
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.twitter,
                color: Colors.lightBlue,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.apple, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Không có tài khoản?"),
            TextButton(
              onPressed: widget.onSwitch,
              child: const Text(
                "Đăng ký",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}
