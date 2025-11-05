import 'package:flutter/material.dart';
import 'dart:async';

class ForgotPasswordForm extends StatefulWidget {
  final VoidCallback onSwitch;
  final VoidCallback onNextStep;
  const ForgotPasswordForm({
    super.key,
    required this.onSwitch,
    required this.onNextStep,
  });

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordForm();
}

class _ForgotPasswordForm extends State<ForgotPasswordForm> {
  String _email = "";
  String _otpCode = "";
  bool _isButtonDisabled = false;
  int _secondsRemaining = 0;
  Timer? _timer;

  void _startCountDown() {
    setState(() {
      _isButtonDisabled = true;
      _secondsRemaining = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 1) {
          _secondsRemaining--;
        } else {
          _secondsRemaining = 0;
          _isButtonDisabled = false;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
            labelText: "Nhập mã",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            labelStyle: const TextStyle(fontStyle: FontStyle.italic),
            suffixIcon: TextButton(
              onPressed: _isButtonDisabled
                  ? null
                  : () {
                      // Api get one-time-token
                      _startCountDown();
                    },
              child: _isButtonDisabled
                  ? Text(
                      "Mã mới sau $_secondsRemaining s",
                      style: const TextStyle(color: Colors.grey),
                    )
                  : const Text(
                      "Lấy mã",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _otpCode = value;
            });
          },
        ),

        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton(
            onPressed: () {
              print("Email: $_email");
              print("Password: $_otpCode");

              widget.onNextStep();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Tiếp theo",
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
