import 'package:project_e_qr_app/main.dart';

/// Generic function to check if a value exists in the database
/// 
/// Note: Do not expose this to untrusted user inputs
Future<bool> checkDuplicateAttribute(String tableName, String attribute, String targetValue) async {
  final result = await db.execute(
    'SELECT 1 FROM $tableName WHERE $attribute = ? LIMIT 1',
    [targetValue],
  );
  return result.isNotEmpty;
}