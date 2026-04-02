import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:powersync/powersync.dart';
import 'package:project_e_qr_app/features/qr_scanner/qr_scanner_page.dart';
import 'package:project_e_qr_app/features/registration/registration_page.dart';
import 'package:project_e_qr_app/features/registration/staff_authorization_page.dart';
import 'package:project_e_qr_app/features/registration/success_page.dart';
import 'package:project_e_qr_app/powersync/powersync.dart';
import 'package:project_e_qr_app/powersync/tables_reader.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late PowerSyncDatabase db;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  if (supabaseUrl != null && supabaseUrl.isNotEmpty &&
      supabaseAnonKey != null && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  await openDatabase();
  await TablesReader.printTables(db);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
