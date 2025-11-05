import 'package:flutter/material.dart';
import '../widgets/login_screen_widgets/login_form.dart';
import '../widgets/login_screen_widgets/signup_form.dart';
import '../widgets/login_screen_widgets/forgot_password_form.dart';
import '../widgets/login_screen_widgets/change_password_form.dart';

enum AuthFormType { login, signup, forgotPassword, changePassword }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  bool _isExpanded = false;
  AuthFormType _currentForm = AuthFormType.login;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(() {
      if (_sheetController.size >= 0.75 && !_isExpanded) {
        setState(() => _isExpanded = true);
      } else if (_sheetController.size < 0.75 && _isExpanded) {
        setState(() {
          _isExpanded = false;
          _currentForm = AuthFormType.login;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Nền gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigoAccent, Colors.indigo.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          const Positioned(
            left: 24,
            bottom: 100,
            child: Text(
              "Khám phá\nthế giới sự kiện",
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (_isExpanded)
            const Positioned(
              top: 50,
              left: 24,
              child: Text(
                "Xin chào.",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (_isExpanded)
            Positioned(
              top: 85,
              left: 24,
              child: Text(
                switch (_currentForm) {
                  AuthFormType.login => "Mừng bạn quay lại!",
                  AuthFormType.signup => "Tạo tài khoản mới!",
                  AuthFormType.forgotPassword => "Quên mật khẩu?",
                  AuthFormType.changePassword => "Đổi mật khẩu!",
                },
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Form tách riêng
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.09,
            minChildSize: 0.09,
            maxChildSize: 0.8,
            snap: true,
            snapSizes: const [0.09, 0.8],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Builder(
                    builder: (context) {
                      switch (_currentForm) {
                        case AuthFormType.login:
                          return LoginForm(
                            key: const ValueKey("login"),
                            onSwitch: () {
                              setState(
                                () => _currentForm = AuthFormType.signup,
                              );
                            },
                            onForgotPasswordButton: () {
                              setState(
                                () =>
                                    _currentForm = AuthFormType.forgotPassword,
                              );
                            },
                          );
                        case AuthFormType.signup:
                          return SignupForm(
                            key: const ValueKey("signup"),
                            onSwitch: () {
                              setState(() => _currentForm = AuthFormType.login);
                            },
                          );
                        case AuthFormType.forgotPassword:
                          return ForgotPasswordForm(
                            key: const ValueKey("forgot"),
                            onSwitch: () {
                              setState(() => _currentForm = AuthFormType.login);
                            },
                            onNextStep: () {
                              setState(
                                () =>
                                    _currentForm = AuthFormType.changePassword,
                              );
                            },
                          );
                        case AuthFormType.changePassword:
                          return ChangePasswordForm(
                            key: const ValueKey("change"),
                            onSwitch: () {
                              setState(() => _currentForm = AuthFormType.login);
                            },
                          );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
