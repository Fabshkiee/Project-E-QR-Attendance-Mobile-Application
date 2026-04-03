import 'package:powersync/powersync.dart';

class QRValidatorResult {
  final bool isValid;
  final String message;

  const QRValidatorResult({required this.isValid, required this.message});
}

class QrValidator {
  static Future<QRValidatorResult> validate(
    PowerSyncDatabase db,
    String? scannedValue,
  ) async {
    print('✅ Processing QR code: $scannedValue');

    final List<String> qrParts = scannedValue?.split(':') ?? [];

    if (qrParts.length < 4) {
      return QRValidatorResult(isValid: false, message: 'Invalid QR format');
    }

    final String org = qrParts[0];
    String user = qrParts[1];
    final String uid = qrParts[2];
    final String qrToken = qrParts[3];

    if (org != "PROJE") {
      return QRValidatorResult(isValid: false, message: 'Invalid QR Code');
    }

    if (user != "MEM" && user != "STAFF" && user != "ADMIN") {
      return QRValidatorResult(
        isValid: false,
        message: 'Invalid user role in QR Code',
      );
    }

    // If member, staff or admin
    if (user == 'MEM') {
      user = "Member";
    } else if (user == 'STAFF') {
      user = "Staff";
    } else if (user == 'ADMIN') {
      user = "Admin";
    }

    final matchedUser = await db.getAll(
      'SELECT * FROM users WHERE short_id = ? AND role = ?',
      [uid, user],
    );

    // if ID with role Member exists
    if (matchedUser.isEmpty) {
      return QRValidatorResult(
        isValid: false,
        message: 'No user found with ID $uid and role $user',
      );
    }

    final validToken = await db.getAll(
      'SELECT * FROM users WHERE short_id = ? AND role = ? AND qr_token = ?',
      [uid, user, qrToken],
    );

    // if User has valid QR token
    if (validToken.isEmpty) {
      return QRValidatorResult(
        isValid: false,
        message: 'Invalid or expired QR token for user $uid',
      );
    }

    return QRValidatorResult(isValid: true, message: 'QR code is valid');
  }
}
