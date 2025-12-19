import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting('vi_VN', null);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: AuthProvider.instance)],
      child: const MainApp(),
    ),
  );

  /* To get User state in Provider from anywhere:
  
  final auth = context.watch<AuthProvider>();
  Text = auth.currentUser!.name
  */
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginScreen());
  }
}
