import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

void main() {
  initializeDateFormatting('vi_VN', null);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: AuthProvider.instance)],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginScreen());
  }
}
