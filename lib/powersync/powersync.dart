import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import '../main.dart';
import '../models/schema.dart';

openDatabase() async {
  final dir = await getApplicationSupportDirectory();
  final path = join(dir.path, 'powersync-dart.db');

  // Set up the database
  // Inject the Schema you defined in the previous step and a file path
  db = PowerSyncDatabase(schema: schema, path: path);
  await db.initialize();
}