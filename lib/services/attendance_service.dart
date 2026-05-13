import 'package:powersync/powersync.dart';
import 'package:uuid/uuid.dart';

class AttendanceService {
  /// Log a member's attendance scan into the attendance_logs table.
  static Future<void> logMemberAttendance({
    required PowerSyncDatabase db,
    required String userId,
    required String memberStatus,
    required String checkInTime,
  }) async {
    await db.execute(
      'INSERT INTO attendance_logs (id, user_id, status_at_scan, check_in_time, created_at) VALUES (?, ?, ?, ?, ?)',
      [const Uuid().v4(), userId, memberStatus, checkInTime, checkInTime],
    );
  }

  /// Log a staff member's attendance scan and update their last_active timestamp.
  static Future<void> logStaffAttendance({
    required PowerSyncDatabase db,
    required String userId,
    required String checkInTime,
  }) async {
    const staffStatus = 'Active';

    await db.execute(
      'UPDATE staff SET last_active = ? WHERE id = ?',
      [checkInTime, userId],
    );

    await db.execute(
      'INSERT INTO attendance_logs (id, user_id, status_at_scan, check_in_time, created_at) VALUES (?, ?, ?, ?, ?)',
      [const Uuid().v4(), userId, staffStatus, checkInTime, checkInTime],
    );
  }
}