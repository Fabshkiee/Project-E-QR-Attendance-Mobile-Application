import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../models/schema.dart';
import 'supabase_connector.dart';

Future<void> openDatabase() async {
  final dir = await getApplicationSupportDirectory();
  final path = join(dir.path, 'powersync-dart.db');

  // Set up the database
  // Inject the Schema you defined in the previous step and a file path
  db = PowerSyncDatabase(schema: schema, path: path);
  await db.initialize();

  // Create attendance_logs as a local-only table (not synced via PowerSync).
  // This fallback stores scans when offline; they are later retried via
  // AttendanceRemoteService.retryQueuedLogs().
  await db.execute('''
    CREATE TABLE IF NOT EXISTS attendance_logs (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      status_at_scan TEXT NOT NULL,
      check_in_time TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
  ''');

  // Connect to the backend
  final connector = SupabaseConnector(Supabase.instance.client);
  db.connect(connector: connector);
}