import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:powersync/powersync.dart';

class AttendanceRemoteService {
  static bool _isOnline = false;
  static PowerSyncDatabase? _db;

  static Future<void> init(PowerSyncDatabase db) async {
    _db = db;
    final results = await Connectivity().checkConnectivity();
    _updateOnlineStatus(results);

    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _updateOnlineStatus(results);

      print('[AttendanceRemoteService] Connectivity changed: wasOnline=$wasOnline, _isOnline=$_isOnline');

      // When coming back online, retry any queued attendance logs
      if (!wasOnline && _isOnline && _db != null) {
        print('[AttendanceRemoteService] Back online — triggering retryQueuedLogs');
        retryQueuedLogs(_db!).then((_) {
          print('[AttendanceRemoteService] retryQueuedLogs completed');
        }).catchError((e) {
          print('[AttendanceRemoteService] retryQueuedLogs failed: $e');
        });
      }
    });
  }

  static void _updateOnlineStatus(List<ConnectivityResult> results) {
    _isOnline = results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }

  /// Normalize raw member status string to match Supabase enum values.
  /// Supabase enum: 'Active', 'Expired', 'Inactive', 'Expiring'
  static String _normalizeMemberStatus(String raw) {
    final lower = raw.toLowerCase().trim();
    if (lower == 'active') return 'Active';
    if (lower == 'expired') return 'Expired';
    if (lower == 'inactive') return 'Inactive';
    if (lower == 'expiring') return 'Expiring';
    // Default to 'Active' for any unknown value
    return 'Active';
  }

  /// Write attendance directly to Supabase via REST API.
  /// On failure or offline, falls back to the local attendance_logs table for later retry.
  static Future<void> logMemberAttendance({
    required PowerSyncDatabase db,
    required String userId,
    required String memberStatus,
    required String checkInTime,
  }) async {
    final rowId = const Uuid().v4();
    // Normalize memberStatus to match Supabase enum values (capitalized).
    // Values: 'Active', 'Expired', 'Inactive', 'Expiring'
    final normalizedStatus = _normalizeMemberStatus(memberStatus);

    if (_isOnline) {
      try {
        await Supabase.instance.client.from('attendance_logs').insert({
          'id': rowId,
          'user_id': userId,
          'status_at_scan': normalizedStatus,
          'check_in_time': checkInTime,
          'created_at': checkInTime,
        });
        print('[AttendanceRemoteService] logMemberAttendance: written to Supabase (online). status=$normalizedStatus');
        return;
      } catch (e) {
        print('[AttendanceRemoteService] logMemberAttendance: Supabase insert FAILED, falling back to local. Error: $e');
      }
    } else {
      print('[AttendanceRemoteService] logMemberAttendance: offline, writing to local DB');
    }

    // Offline or API error — write locally so it can be synced later
    await db.execute(
      'INSERT INTO attendance_logs (id, user_id, status_at_scan, check_in_time, created_at) VALUES (?, ?, ?, ?, ?)',
      [rowId, userId, normalizedStatus, checkInTime, checkInTime],
    );
    print('[AttendanceRemoteService] logMemberAttendance: written to local DB. id=$rowId, status=$normalizedStatus');
  }

  /// Log staff attendance and update last_active directly on Supabase.
  /// On failure or offline, falls back to local storage.
  static Future<void> logStaffAttendance({
    required PowerSyncDatabase db,
    required String userId,
    required String checkInTime,
  }) async {
    final rowId = const Uuid().v4();

    if (_isOnline) {
      try {
        // Update last_active on Supabase
        await Supabase.instance.client
            .from('staff')
            .update({'last_active': checkInTime}).eq('id', userId);

        // Insert attendance log on Supabase
        await Supabase.instance.client.from('attendance_logs').insert({
          'id': rowId,
          'user_id': userId,
          'status_at_scan': 'Active',
          'check_in_time': checkInTime,
          'created_at': checkInTime,
        });
        print('[AttendanceRemoteService] logStaffAttendance: written to Supabase (online). staff.last_active updated.');
        return;
      } catch (e) {
        print('[AttendanceRemoteService] logStaffAttendance: Supabase insert FAILED, falling back to local. Error: $e');
        // Fall through to local write on error
      }
    } else {
      print('[AttendanceRemoteService] logStaffAttendance: offline, writing to local DB');
    }

    // Offline or API error — write locally as fallback
    await db.execute(
      'INSERT INTO attendance_logs (id, user_id, status_at_scan, check_in_time, created_at) VALUES (?, ?, ?, ?, ?)',
      [rowId, userId, 'Active', checkInTime, checkInTime],
    );
    await db.execute(
      'UPDATE staff SET last_active = ? WHERE id = ?',
      [checkInTime, userId],
    );
    print('[AttendanceRemoteService] logStaffAttendance: written to local DB. id=$rowId, staff.last_active updated locally');
  }

  /// Retry any locally queued attendance logs that failed to upload.
  /// Call this periodically or on app resume / reconnect.
  static Future<void> retryQueuedLogs(PowerSyncDatabase db) async {
    print('[AttendanceRemoteService] retryQueuedLogs: starting...');

    final rows = await db.getAll(
      'SELECT id, user_id, status_at_scan, check_in_time FROM attendance_logs ORDER BY check_in_time ASC',
    );

    if (rows.isEmpty) {
      print('[AttendanceRemoteService] retryQueuedLogs: no queued rows to upload');
      return;
    }

    print('[AttendanceRemoteService] retryQueuedLogs: found ${rows.length} queued row(s)');

    for (final row in rows) {
      final rowId = row['id'] as String;
      final userId = row['user_id'] as String;
      final statusAtScan = _normalizeMemberStatus(row['status_at_scan'] as String);
      final checkInTime = row['check_in_time'] as String;

      print('[AttendanceRemoteService] retryQueuedLogs: uploading row id=$rowId, user_id=$userId');

      try {
        await Supabase.instance.client.from('attendance_logs').insert({
          'id': rowId,
          'user_id': userId,
          'status_at_scan': statusAtScan,
          'check_in_time': checkInTime,
          'created_at': checkInTime,
        });

        // If this is staff attendance, also update last_active on Supabase
        if (statusAtScan == 'Active') {
          print('[AttendanceRemoteService] retryQueuedLogs: updating staff.last_active for user_id=$userId');
          await Supabase.instance.client
              .from('staff')
              .update({'last_active': checkInTime}).eq('id', userId);
        }

        // Remove from local queue on success
        await db.execute('DELETE FROM attendance_logs WHERE id = ?', [rowId]);
        print('[AttendanceRemoteService] retryQueuedLogs: row id=$rowId uploaded and deleted from local queue');
      } on PostgrestException catch (e) {
        // 409 conflict means row already exists in Supabase — delete locally and continue
        if (e.code == '23505') {
          print('[AttendanceRemoteService] retryQueuedLogs: 409 duplicate for row id=$rowId — deleting locally');
          await db.execute('DELETE FROM attendance_logs WHERE id = ?', [rowId]);
          continue;
        }
        print('[AttendanceRemoteService] retryQueuedLogs: PostgrestException for row id=$rowId: ${e.message}, code=${e.code}');
        // Network error or other — stop retrying, remaining items will retry next time
        break;
      } on SocketException catch (e) {
        print('[AttendanceRemoteService] retryQueuedLogs: SocketException (no network) for row id=$rowId: $e');
        break;
      } catch (e) {
        print('[AttendanceRemoteService] retryQueuedLogs: Unexpected error for row id=$rowId: $e');
        break;
      }
    }

    print('[AttendanceRemoteService] retryQueuedLogs: done');
  }
}