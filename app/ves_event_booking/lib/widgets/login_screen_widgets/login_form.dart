import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ves_event_booking/screens/home_screen.dart';

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
  String _email = "";
  String _password = "";
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
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
            labelText: "Email",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            labelStyle: const TextStyle(fontStyle: FontStyle.italic),
          ),
          onChanged: (value) {
            setState(() {
              _email = value;
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
            onPressed: () async {
              print("Email: $_email");
              print("Password: $_password");
              print("Remember: $_rememberMe");

              /* Use these services when have API
              try {
                final auth = context.read<AuthProvider>();
                await auth.login(_email, _password);

                // Login -> navigation
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đăng nhập thất bại: $e')),
                  );
                }
              }
              */
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
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
