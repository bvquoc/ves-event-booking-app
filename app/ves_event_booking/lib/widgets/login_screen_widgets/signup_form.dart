import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần thêm package này để format ngày tháng (hoặc tự format String)
import 'package:ves_event_booking/models/auth/register_request.dart';
import '../dialog.dart';
import 'package:provider/provider.dart';
import 'package:ves_event_booking/providers/auth_provider.dart';

class SignupForm extends StatefulWidget {
  final VoidCallback onSwitch;
  const SignupForm({super.key, required this.onSwitch});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  // 1. Cập nhật các biến state theo Model
  String _username = "";
  String _firstName = "";
  String _lastName = "";
  String _email = "";
  String _phone = "";
  String _password = "";
  DateTime? _dob;

  // Controller cho ô ngày sinh để hiển thị text
  final TextEditingController _dobController = TextEditingController();

  bool _isButtonEnabled = false;

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  // 2. Logic validate kiểm tra đủ 7 trường
  void _validateInputs() {
    final isValid =
        _username.trim().isNotEmpty &&
        _firstName.trim().isNotEmpty &&
        _lastName.trim().isNotEmpty &&
        _email.trim().isNotEmpty &&
        _phone.trim().isNotEmpty &&
        _password.trim().isNotEmpty &&
        _dob != null; // Kiểm tra ngày sinh đã chọn chưa

    if (_isButtonEnabled != isValid) {
      setState(() {
        _isButtonEnabled = isValid;
      });
    }
  }

  // Hàm hiển thị lịch chọn ngày sinh
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // Mặc định 18 tuổi
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'), // Nếu app có hỗ trợ tiếng Việt
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
        // Format hiển thị dd/MM/yyyy
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        _validateInputs();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 60,
            height: 4,
            margin: const EdgeInsets.only(
              bottom: 30,
            ), // Giảm margin chút cho đỡ dài
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // --- 3. UI Nhập liệu mới ---

        // Username
        TextField(
          decoration: _buildInputDecoration("Tên đăng nhập (Username)"),
          onChanged: (value) {
            setState(() {
              _username = value;
              _validateInputs();
            });
          },
        ),
        const SizedBox(height: 16),

        // Họ và Tên (Nằm trên 1 hàng cho gọn)
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: _buildInputDecoration("Họ"),
                onChanged: (value) {
                  setState(() {
                    _lastName = value;
                    _validateInputs();
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: _buildInputDecoration("Tên"),
                onChanged: (value) {
                  setState(() {
                    _firstName = value;
                    _validateInputs();
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Ngày sinh (ReadOnly - Bấm vào hiện lịch)
        TextField(
          controller: _dobController,
          readOnly: true,
          decoration: _buildInputDecoration("Ngày sinh (dd/mm/yyyy)").copyWith(
            suffixIcon: const Icon(
              Icons.calendar_today,
              size: 20,
              color: Colors.grey,
            ),
          ),
          onTap: () => _selectDate(context),
        ),
        const SizedBox(height: 16),

        // Email
        TextField(
          decoration: _buildInputDecoration("Email"),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            setState(() {
              _email = value;
              _validateInputs();
            });
          },
        ),
        const SizedBox(height: 16),

        // Số điện thoại
        TextField(
          decoration: _buildInputDecoration("Số điện thoại"),
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            setState(() {
              _phone = value;
              _validateInputs();
            });
          },
        ),
        const SizedBox(height: 16),

        // Mật khẩu
        TextField(
          obscureText: true,
          decoration: _buildInputDecoration("Mật khẩu"),
          onChanged: (value) {
            setState(() {
              _password = value;
              _validateInputs();
            });
          },
        ),
        const SizedBox(height: 24),

        // --- Nút Đăng Ký ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton(
            onPressed: (_isButtonEnabled && !authProvider.isLoading)
                ? () async {
                    // 4. Gọi API với đầy đủ thông tin
                    // Lưu ý: Bạn cần cập nhật hàm register bên AuthProvider để nhận các tham số này
                    // Hoặc truyền object RegisterRequest vào
                    bool success = await authProvider.register(
                      RegisterRequest(
                        username: _username,
                        password: _password,
                        email: _email,
                        phone: _phone,
                        firstName: _firstName,
                        lastName: _lastName,
                        dob: _dob!,
                      ),
                    );

                    if (success) {
                      if (!mounted) return;
                      showSuccessDialog(
                        context: context,
                        message: "Đăng ký thành công tài khoản mới",
                        icon: Icons.thumb_up_alt_outlined,
                        closeText: "Đăng nhập ngay",
                        onOk: widget.onSwitch,
                      );
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            authProvider.errorMessage ?? 'Lỗi đăng ký',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 12),
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

  // Helper để tái sử dụng style decoration
  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      labelStyle: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      isDense: true,
    );
  }
}
