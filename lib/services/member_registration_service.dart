import 'dart:math';

import 'package:project_e_qr_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Handles credential generation, staff qr validation, 
/// and write to local db operations for new users
class MemberRegistrationService {
  MemberRegistrationService._();

  /// Writes the new member to local db
  static Future<void> registerNewUser(Map<String, dynamic> userData) async {
    await generateMemberCredentials(userData);

    await db.writeTransaction((tx) async {
      await tx.execute('''
        INSERT INTO users (id, short_id, first_name, last_name, nickname, role, qr_token)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''', [
        userData['id'], 
        userData['short_id'], 
        userData['first_name'], 
        userData['last_name'],
        userData['nickname'], 
        'Member', 
        userData['qr_token']
      ]);

      await tx.execute('''
        INSERT INTO members (id, status, started_date, valid_until, membership_type_id, coach_id, is_discounted)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''', [
        userData['id'], 
        'Active', 
        userData['started_date'],
        userData['valid_until'],
        userData['membership_type_id'], 
        userData['coach_id'],
        userData['is_discounted']
      ]);
    });

    // Write renewal log directly to Supabase — fire-and-forget retry
    // because PowerSync needs time to sync the member row first (FK constraint)
    _insertRenewalLog(userData);
  }

  /// Inserts a renewal log entry to Supabase with retries.
  /// Runs in background so it doesn't block the registration flow.
  static Future<void> _insertRenewalLog(Map<String, dynamic> userData) async {
    final payload = {
      'id': const Uuid().v4(),
      'member_id': userData['id'],
      'membership_type_id': userData['membership_type_id'],
      'valid_from': userData['started_date'],
      'valid_until': userData['valid_until'],
      'is_discounted': userData['is_discounted'] == true,
      'fee_applied': userData['total_fee'] ?? 0.0,
      'is_new_member': true,
    };

    for (int attempt = 1; attempt <= 5; attempt++) {
      await Future.delayed(Duration(seconds: attempt * 2));
      try {
        await Supabase.instance.client.from('member_renewal_logs').insert(payload);
        print('[MemberRegistrationService] Renewal log written (attempt $attempt)');
        return;
      } catch (e) {
        print('[MemberRegistrationService] Renewal log attempt $attempt failed: $e');
      }
    }
    print('[MemberRegistrationService] Renewal log failed after 5 attempts');
  }

  /// Generates the necessary fields after the user fills in the fields
  /// from the registration form
  static Future<void> generateMemberCredentials(Map<String, dynamic> userData) async {
    userData['id'] = const Uuid().v4(); // Generate UUID 
    userData['short_id'] = await generateUniqueShortId();
    userData['qr_token'] = await generateUniqueQrToken();

    // Generate password: lowercase stripped first_name + short_id
    final firstName = (userData['first_name'] as String?) ?? '';
    final shortId = userData['short_id'] as String;
    userData['password'] = firstName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '') + shortId;

    /// Initialize membership duration
    DateTime today = DateTime.now();
    DateTime until = DateTime(
      today.year, 
      today.month + (userData['membership_duration'] as int), 
      today.day, 
      today.hour, 
      today.minute
    );

    userData['started_date'] = today.toIso8601String();
    userData['valid_until'] = until.toIso8601String();
  }

  /// Generates a unique value for `attribute` in `tableName`, retrying up to 100 times if a duplicate is found.
  /// Throws an `Exception` if no unique value could be generated after `maxAttempts` 
  /// Failure reason: Table is likely full.
  static Future<String> _generateUnique(String tableName, String attribute, String Function() generator) async {
    const int maxAttempts = 100;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final candidate = generator();
      final result = await db.getOptional(
        'SELECT 1 FROM $tableName WHERE $attribute = ? LIMIT 1',
        [candidate],
      );

      if (result == null) return candidate;
    }

    throw Exception('Failed to generate a unique $attribute after $maxAttempts attempts. Try Again');
  }

  /// Random ID generation strategy uses 2 digits of time + 2 digits of a random number
  /// In order to spread out the likelihood of encountering a collision. 
  static Future<String> generateUniqueShortId() async {
    return _generateUnique('users', 'short_id', () {
      final timePart = (DateTime.now().millisecondsSinceEpoch % 100).toString().padLeft(2, '0');
      final randomPart = Random().nextInt(100).toString().padLeft(2, '0');
      return 'L$timePart$randomPart';
    });
  }

  static Future<String> generateUniqueQrToken() async {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    return _generateUnique('users', 'qr_token', () {
      return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
    });
  }
}
