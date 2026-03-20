import 'package:flutter/material.dart';
import 'package:project_e_qr_app/features/qr_scanner/qr_scanner_page.dart';
import 'package:project_e_qr_app/features/registration/registration_page.dart';
import 'package:project_e_qr_app/features/registration/staff_authorization_page.dart';
import 'package:project_e_qr_app/features/registration/success_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project-E Fitness Gym',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const QRScannerPage(),
        '/registration': (context) => const RegistrationPage(),
        '/staff_auth': (context) => const StaffAuthorizationPage(),
        '/success': (context) => const SuccessPage(),
      },
    );
  }
}

