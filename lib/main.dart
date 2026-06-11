import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'pages/splash_screen.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/motor_form_page.dart';
import 'pages/dashboard_page.dart';

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('motor');
  await Hive.openBox('history');

  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔥 START DARI SPLASH
      initialRoute: '/splash',

      // 🔥 ROUTES LENGKAP (WAJIB BIAR GA ERROR LAGI)
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/motor': (_) => const MotorFormPage(),
        '/dashboard': (_) => const DashboardPage(),
      },

      // 🔥 ANIMASI GLOBAL TRANSISI (BIAR PREMIUM)
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case '/login':
            page = const LoginPage();
            break;
          case '/register':
            page = const RegisterPage();
            break;
          case '/motor':
            page = const MotorFormPage();
            break;
          case '/dashboard':
            page = const DashboardPage();
            break;
          default:
            page = const SplashScreen();
        }

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
      },
    );
  }
}