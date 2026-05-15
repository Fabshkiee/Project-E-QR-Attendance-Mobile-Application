import 'package:project_e_qr_app/main.dart';

bool validStaffQrFormat(List<String> parts) {
  return parts[0] == 'PROJE' && parts[1] == 'STAFF';
}

/// Queries the staff table to check if the token belongs to a staff
Future<bool> staffExists(String qrToken, String shortId) async {
  final result = await db.getOptional('''
    SELECT 1 FROM users 
    INNER JOIN staff ON staff.id = users.id
    WHERE users.qr_token = ? AND users.short_id = ?
    LIMIT 1
  ''', [qrToken, shortId]);

  return result != null;
}