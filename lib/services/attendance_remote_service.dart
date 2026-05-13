import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:powersync/powersync.dart';

class AttendanceRemoteService {
  /// Write attendance directly to Supabase via REST API.
  /// On failure, falls back to the local attendance_logs table for later retry.
  static Future<void> logMemberAttendance({
    required PowerSyncDatabase db,
    required String userId,
    required String memberStatus,
    required String checkInTime,
  }) async {
    try {
      await Supabase.instance.client.from('attendance_logs').insert({
        'id': const Uuid().v4(),
        'user_id': userId,
        'status_at_scan': memberStatus,
        'check_in_time': checkInTime,
        'created_at': checkInTime,
      });
    } catch (_) {
      // Offline or API error — write locally so it can be synced later
      await db.execute(
        'INSERT INTO attendance_logs (id, user_id, status_at_scan, check_in_time, created_at) VALUES (?, ?, ?, ?, ?)',
        [const Uuid().v4(), userId, memberStatus, checkInTime, checkInTime],
      );
    }
  }

  /// Log staff attendance and update last_active directly on Supabase.
  /// On failure, falls back to local storage.
  static Future<void> logStaffAttendance({
    required PowerSyncDatabase db,
    required String userId,
    required String checkInTime,
  }) async {
    try {
      // Update last_active on Supabase
      await Supabase.instance.client
          .from('staff')
          .update({'last_active': checkInTime}).eq('id', userId);

      // Insert attendance log on Supabase
      await Supabase.instance.client.from('attendance_logs').insert({
        'id': const Uuid().v4(),
        'user_id': userId,
        'status_at_scan': 'Active',
        'check_in_time': checkInTime,
        'created_at': checkInTime,
      });
    } catch (_) {
      // Offline or API error — write locally as fallback
      await db.execute(
        'INSERT INTO attendance_logs (id, user_id, status_at_scan, check_in_time, created_at) VALUES (?, ?, ?, ?, ?)',
        [const Uuid().v4(), userId, 'Active', checkInTime, checkInTime],
      );
      await db.execute(
        'UPDATE staff SET last_active = ? WHERE id = ?',
        [checkInTime, userId],
      );
    }
  }

  /// Retry any locally queued attendance logs that failed to upload.
  /// Call this periodically or on app resume / reconnect.
  static Future<void> retryQueuedLogs(PowerSyncDatabase db) async {
    final rows = await db.getAll(
      'SELECT id, user_id, status_at_scan, check_in_time FROM attendance_logs ORDER BY check_in_time ASC',
    );

    for (final row in rows) {
      try {
        await Supabase.instance.client.from('attendance_logs').insert({
          'id': row['id'],
          'user_id': row['user_id'],
          'status_at_scan': row['status_at_scan'],
          'check_in_time': row['check_in_time'],
          'created_at': row['check_in_time'],
        });

        // Remove from local queue on success
        await db.execute(
          'DELETE FROM attendance_logs WHERE id = ?',
          [row['id']],
        );
      } catch (_) {
        // Stop retrying on first failure — remaining items will retry next time
        break;
      }
    }
  }
}