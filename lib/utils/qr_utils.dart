import 'package:project_e_qr_app/main.dart';

List<String>? splitQr(String qr) {
  final parts = qr.split(':');
  return parts.length == 4 ? parts : null;
}

bool isStaffQr(List<String> parts) {
  return parts[0] == 'PROJE' && parts[1] == 'STAFF';
}

/// Queries the staff table to check if the token belongs to a staff
Future<bool> staffQrExists(String qrToken) async {
  final result = await db.getOptional('''
    SELECT 1 FROM users 
    INNER JOIN staff ON staff.id = users.id 
    WHERE users.qr_token = ? 
    LIMIT 1
  ''', [qrToken]);

  return result != null;
}