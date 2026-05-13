import 'package:powersync/powersync.dart';
import 'package:project_e_qr_app/services/recent_scan_cache.dart';

final _scanCache = RecentScanCache();

class QRValidatorResult {
  final bool isValid;
  final String message;
  final String fullName;
  final String checkInTime;
  final String memberStatus;
  final DateTime? validUntil;
  final String? userId;

  const QRValidatorResult({
    required this.isValid,
    required this.message,
    required this.fullName,
    required this.checkInTime,
    required this.memberStatus,
    this.validUntil,
    this.userId,
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
        memberStatus: '',
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
        memberStatus: '',
      );
    }

    if (userType != "MEM" && userType != "STAFF" && userType != "ADMIN") {
      return QRValidatorResult(
        isValid: false,
        message: 'Invalid user role in QR Code',
        fullName: '',
        checkInTime: '',
        memberStatus: '',
      );
    }

    // Map QR type to expected DB roles
    // MEM → Member only
    // STAFF → Staff or Admin
    // ADMIN → Staff or Admin
    final List<String> allowedDbRoles;
    if (userType == 'MEM') {
      allowedDbRoles = ['Member'];
    } else {
      // STAFF and ADMIN both accept Staff or Admin in DB
      allowedDbRoles = ['Staff', 'Admin'];
    }

    final rows = await db.getAll(
      '''
        SELECT
          u.id,
          u.role,
          COALESCE(NULLIF(u.nickname, ''), u.full_name) AS display_name,
          m.status AS member_status,
          m.valid_until
        FROM users u
        LEFT JOIN members m ON m.id = u.id
        WHERE u.short_id = ? AND u.qr_token = ?
        LIMIT 1
        ''',
      [uid, qrToken],
    );

    if (rows.isEmpty) {
      return QRValidatorResult(
        isValid: false,
        message: userType == 'MEM' ? 'Invalid Member ID or Token' : 'Invalid Staff ID or Token',
        fullName: '',
        checkInTime: '',
        memberStatus: '',
      );
    }

    final row = rows.first;
    final dbUserRole = (row['role'] ?? '').toString();

    // Validate that the DB role is in the allowed roles for this QR type
    if (!allowedDbRoles.contains(dbUserRole)) {
      return QRValidatorResult(
        isValid: false,
        message: userType == 'MEM' ? 'Invalid Member ID or Token' : 'Invalid Staff ID or Token',
        fullName: '',
        checkInTime: '',
        memberStatus: '',
      );
    }

    final userId = (row['id'] ?? '').toString();
    final memberStatus = (row['member_status'] ?? '').toString().toLowerCase();
    final validUntilRaw = (row['valid_until'] ?? '').toString();
    final validUntil = DateTime.tryParse(validUntilRaw);

    final nowUtc = DateTime.now().toUtc();
    final nowIso = nowUtc.toIso8601String();
    const staffStatus = 'Active';

    if (userType == 'MEM') {
      if (memberStatus != 'active' && memberStatus == 'expired') {
        return QRValidatorResult(
          isValid: false,
          message: 'Membership is not active: $memberStatus',
          fullName: '',
          checkInTime: '',
          memberStatus: memberStatus,
        );
      }

      // final today = DateTime(nowUtc.year, nowUtc.month, nowUtc.day).toUtc();
      // if (validUntil != null && validUntil.isBefore(today)) {
      //   return QRValidatorResult(
      //     isValid: false,
      //     message: 'Membership expired on $validUntilRaw',
      //     fullName: '',
      //     checkInTime: '',
      //   );
      // }

      // In-memory duplicate scan check — avoids querying attendance_logs,
      // which is no longer synced via PowerSync to break the realtime loop.
      if (_scanCache.isDuplicate(userId)) {
        return QRValidatorResult(
          isValid: false,
          message: 'Duplicate scan. Please wait a moment.',
          fullName: (row['display_name'] ?? '').toString(),
          checkInTime: nowIso,
          memberStatus: memberStatus,
          validUntil: validUntil,
          userId: userId,
        );
      }

      _scanCache.recordScan(userId, nowUtc);

      return QRValidatorResult(
        isValid: true,
        message: 'Member validated successfully',
        fullName: (row['display_name'] ?? '').toString(),
        checkInTime: nowIso,
        memberStatus: memberStatus,
        validUntil: validUntil,
        userId: userId,
      );
    }

    // Staff scan — also check in-memory duplicate for staff
    if (_scanCache.isDuplicate(userId)) {
      return QRValidatorResult(
        isValid: false,
        message: 'Duplicate scan. Please wait a moment.',
        fullName: (row['display_name'] ?? '').toString(),
        checkInTime: nowIso,
        memberStatus: staffStatus,
        userId: userId,
      );
    }

    _scanCache.recordScan(userId, nowUtc);

    return QRValidatorResult(
      isValid: true,
      message: 'Staff validated successfully',
      fullName: (row['display_name'] ?? '').toString(),
      checkInTime: nowIso,
      memberStatus: staffStatus,
      userId: userId,
    );
  }
}
