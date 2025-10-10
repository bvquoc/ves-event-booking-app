import 'package:flutter/material.dart';
import '../widgets/dialog.dart';

class ChangePasswordForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const ChangePasswordForm({super.key, required this.onSwitch});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordForm();
}

class _ChangePasswordForm extends State<ChangePasswordForm> {
  String _newPass = "";
  String _confirmPass = "";

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
            labelText: "Mật khẩu cũ",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            labelStyle: const TextStyle(fontStyle: FontStyle.italic),
          ),
          onChanged: (value) {
            setState(() {
              _newPass = value;
            });
          },
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Mật khẩu mới",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            labelStyle: const TextStyle(fontStyle: FontStyle.italic),
          ),
          onChanged: (value) {
            setState(() {
              _confirmPass = value;
            });
          },
        ),

        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton(
            onPressed: () {
              print("New password: $_newPass");
              print("Confirm password: $_confirmPass");

              showSuccessDialog(
                context: context,
                message: "Đổi mật khẩu thành công",
                icon: Icons.check_circle_outline,
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
              "xác nhận",
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
            const Text("Thực hiện đăng nhập?"),
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
