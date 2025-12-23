import 'package:flutter/material.dart';
import 'package:ves_event_booking/providers/event_provider.dart';
import 'package:ves_event_booking/providers/home_provider.dart';
import 'package:ves_event_booking/providers/notification_provider.dart';
import 'package:ves_event_booking/providers/ticket_provider.dart';
import 'package:ves_event_booking/providers/user_provider.dart';
import 'screens/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  initializeDateFormatting('vi_VN', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AuthProvider.instance),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ves Event Booking',
      debugShowCheckedModeBanner: false,

      // 2. THÊM ĐOẠN NÀY ĐỂ SỬA LỖI
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // Tiếng Anh
        Locale('vi', ''), // Tiếng Việt (cho lịch hiển thị tiếng Việt)
      ],

      // -----------------------------
      home: const LoginScreen(), // (Màn hình chính của bạn)
    );
  }
}
