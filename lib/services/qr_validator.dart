import 'package:powersync/powersync.dart';
import 'package:uuid/uuid.dart';

class QRValidatorResult {
  final bool isValid;
  final String message;
  final String fullName;
  final String checkInTime;

  const QRValidatorResult({
    required this.isValid,
    required this.message,
    required this.fullName,
    required this.checkInTime,
  });
}

class QrValidator {
  static Future<QRValidatorResult> validate(
    PowerSyncDatabase db,
    String? scannedValue,
  ) async {
    print('✅ Processing QR code: $scannedValue');

    final List<String> qrParts = scannedValue?.split(':') ?? [];

    if (qrParts.length != 4) {
      return QRValidatorResult(
        isValid: false,
        message: 'Invalid QR format',
        fullName: '',
        checkInTime: '',
      );
    }

    final String org = qrParts[0];
    final String userType = qrParts[1];
    final String uid = qrParts[2];
    final String qrToken = qrParts[3];

    if (org != "PROJE") {
      return QRValidatorResult(
        isValid: false,
        message: 'Invalid QR Code',
        fullName: '',
        checkInTime: '',
      );
    }

    if (userType != "MEM" && userType != "STAFF" && userType != "ADMIN") {
      return QRValidatorResult(
        isValid: false,
        message: 'Invalid user role in QR Code',
        fullName: '',
        checkInTime: '',
      );
    }

    final nowUtc = DateTime.now().toUtc();
    final nowIso = nowUtc.toIso8601String();

    if (userType == 'MEM') {
      final rows = await db.getAll(
        '''
        SELECT
          u.id,
          COALESCE(u.nickname, u.full_name) AS display_name,
          m.status AS member_status,
          m.valid_until
        FROM users u
        JOIN members m ON m.id = u.id
        WHERE u.short_id = ? AND u.qr_token = ? AND u.role = 'Member'
        LIMIT 1
        ''',
        [uid, qrToken],
      );

      if (rows.isEmpty) {
        return const QRValidatorResult(
          isValid: false,
          message: 'Invalid Member ID or Token',
          fullName: '',
          checkInTime: '',
        );
      }

      final row = rows.first;
      final userId = (row['id'] ?? '').toString();
      final memberStatus = (row['member_status'] ?? '')
          .toString()
          .toLowerCase();
      final validUntilRaw = (row['valid_until'] ?? '').toString();
      final validUntil = DateTime.tryParse(validUntilRaw)?.toUtc();

      if (memberStatus != 'active') {
        return QRValidatorResult(
          isValid: false,
          message: 'Membership is not active: $memberStatus',
          fullName: '',
          checkInTime: '',
        );
      }

      final today = DateTime(nowUtc.year, nowUtc.month, nowUtc.day).toUtc();
      if (validUntil != null && validUntil.isBefore(today)) {
        return QRValidatorResult(
          isValid: false,
          message: 'Membership expired on $validUntilRaw',
          fullName: '',
          checkInTime: '',
        );
      }

      final latestLog = await db.getAll(
        'SELECT check_in_time FROM attendance_logs WHERE user_id = ? ORDER BY check_in_time DESC LIMIT 1',
        [userId],
      );

      if (latestLog.isNotEmpty) {
        final lastRaw = (latestLog.first['check_in_time'] ?? '').toString();
        final lastTime = DateTime.tryParse(lastRaw)?.toUtc();
        if (lastTime != null && nowUtc.difference(lastTime).inSeconds < 5) {
          return const QRValidatorResult(
            isValid: false,
            message: 'Duplicate scan. Please wait a moment.',
            fullName: '',
            checkInTime: '',
          );
        }
      }

      await db.execute(
        'INSERT INTO attendance_logs (id, user_id, status_at_scan, check_in_time, created_at) VALUES (?, ?, ?, ?, ?)',
        [const Uuid().v4(), userId, memberStatus, nowIso, nowIso],
      );

      return QRValidatorResult(
        isValid: true,
        message: 'Member attendance logged',
        fullName: (row['display_name'] ?? '').toString(),
        checkInTime: nowIso,
      );
    }

    final rows = await db.getAll(
      '''
      SELECT
        u.id,
        COALESCE(u.nickname, u.full_name) AS display_name,
        u.role
      FROM users u
      JOIN staff s ON s.id = u.id
      WHERE u.short_id = ? AND u.qr_token = ? AND u.role IN ('Staff', 'Admin')
      LIMIT 1
      ''',
      [uid, qrToken],
    );

    if (rows.isEmpty) {
      return const QRValidatorResult(
        isValid: false,
        message: 'Invalid Staff ID or Token',
        fullName: '',
        checkInTime: '',
      );
    }

    final row = rows.first;
    final userId = (row['id'] ?? '').toString();

    await db.execute('UPDATE staff SET last_active = ? WHERE id = ?', [
      nowIso,
      userId,
    ]);

    await db.execute(
      'INSERT INTO attendance_logs (id, user_id, status_at_scan, check_in_time, created_at) VALUES (?, ?, ?, ?, ?)',
      [const Uuid().v4(), userId, null, nowIso, nowIso],
    );

    return QRValidatorResult(
      isValid: true,
      message: 'Member attendance logged',
      fullName: (row['display_name'] ?? '').toString(),
      checkInTime: nowIso,
    );
  }
}
