import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../models/schema.dart';
import 'supabase_connector.dart';

openDatabase() async {
  final dir = await getApplicationSupportDirectory();
  final path = join(dir.path, 'powersync-dart.db');

  // Set up the database
  // Inject the Schema you defined in the previous step and a file path
  db = PowerSyncDatabase(schema: schema, path: path);
  await db.initialize();

  // Connect to the backend
  final connector = SupabaseConnector(Supabase.instance.client);
  db.connect(connector: connector);
}