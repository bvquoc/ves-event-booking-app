import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ves_event_booking/screens/profile/profile_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
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
    return MaterialApp(home: ProfileScreen());
  }
}
