import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:powersync/powersync.dart';
import 'package:project_e_qr_app/features/qr_scanner/qr_scanner_page.dart';
import 'package:project_e_qr_app/features/registration/registration_page.dart';
import 'package:project_e_qr_app/features/registration/staff_authorization_page.dart';
import 'package:project_e_qr_app/features/registration/success_page.dart';
import 'package:project_e_qr_app/powersync/powersync.dart';
import 'package:project_e_qr_app/powersync/tables_reader.dart';
import 'package:project_e_qr_app/features/registration/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late PowerSyncDatabase db;
bool _isDbInitialized = false;

Future<void> ensureDbInitialized() async {
  if (_isDbInitialized) return;

  await openDatabase();
  _isDbInitialized = true;
  await TablesReader.printTables(db);
}

Future<String?> signInWithPasswordAndSync({
  required String email,
  required String password,
}) async {
  try {
    // Ensure the login screen credentials are the active session.
    //if (Supabase.instance.client.auth.currentSession != null) {
    //  await Supabase.instance.client.auth.signOut();
    //}

    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    await ensureDbInitialized();

    return null;
  } on AuthException {
    return 'Invalid email or password';
  } catch (_) {
    return 'Login failed. Please try again.';
  }
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the .env file
  await dotenv.load(fileName: ".env");

  // Get values from environment
  final supabaseUrl = dotenv.env['NEXT_PUBLIC_SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY'];
  
  // Validate that keys exist
  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env file');
  }
  
  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  final hasSession = Supabase.instance.client.auth.currentSession != null;

  if (hasSession) {
    await ensureDbInitialized();
  }

  runApp(MyApp(initialRoute: hasSession ? '/' : '/login'));

}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project-E Fitness Gym',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginWidget(),
        '/': (context) => const QRScannerPage(),
        '/registration': (context) => const RegistrationPage(),
        '/staff_auth': (context) => const StaffAuthorizationPage(),
        '/success': (context) => const SuccessPage(),
      },
    );
  }
}
