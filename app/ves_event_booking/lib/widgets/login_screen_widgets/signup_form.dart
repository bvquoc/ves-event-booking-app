import 'package:flutter/material.dart';
import '../dialog.dart';

class SignupForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const SignupForm({super.key, required this.onSwitch});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  String _name = "";
  String _email = "";
  String _password = "";
  bool _acceptPolicy = false;

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
            labelText: "Họ tên",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            labelStyle: const TextStyle(fontStyle: FontStyle.italic),
          ),
          onChanged: (value) {
            setState(() {
              _name = value;
            });
          },
        ),
        const SizedBox(height: 16),
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
              value: _acceptPolicy,
              onChanged: (v) {
                setState(() {
                  _acceptPolicy = v ?? false;
                });
              },
              activeColor: Colors.green,
            ),
            const Text("Tôi đồng ý với các điều khoản đưa ra"),
          ],
        ),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton(
            onPressed: () {
              print("Name: $_name");
              print("Email: $_email");
              print("Password: $_password");
              print("Remember: $_acceptPolicy");

              showSuccessDialog(
                context: context,
                message: "Đăng ký thành công tài khoản mới",
                icon: Icons.thumb_up_alt_outlined,
                closeText: "Đăng nhập ngay",
                onOk: widget.onSwitch,
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
              "Đăng ký",
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Đã có tài khoản?"),
            TextButton(
              onPressed: widget.onSwitch,
              child: const Text(
                "Đăng nhập",
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
