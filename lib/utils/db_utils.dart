import 'package:project_e_qr_app/main.dart';

/// Checks if a row exists in [tableName] where [attribute] matches [target].
/// Throws if [tableName] or [attribute] does not exist in the database.
/// Note: Do not expose this to untrusted user inputs
Future<bool> attributeExists(String tableName, String attribute, String targetValue) async {
  final result = await db.getOptional(
    'SELECT 1 FROM $tableName WHERE $attribute = ? LIMIT 1',
    [targetValue],
  );
  return result != null;
}