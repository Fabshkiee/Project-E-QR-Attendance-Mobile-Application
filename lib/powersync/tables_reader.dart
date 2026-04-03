import 'package:powersync/powersync.dart';

class TablesReader {
  static Future<void> printTables(PowerSyncDatabase db) async {
    final rows = await db.getAll('SELECT name FROM sqlite_master WHERE type=? ORDER BY name', ['table']);
    for (var row in rows) {
      print('Table: ${row['name']}');
    }
  }
}