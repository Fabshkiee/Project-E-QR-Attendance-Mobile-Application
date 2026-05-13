import 'dart:math';

import 'package:project_e_qr_app/main.dart';
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
        INSERT INTO users (id, short_id, full_name, nickname, role, qr_token)
        VALUES (?, ?, ?, ?, ?, ?)
      ''', [
        userData['id'], 
        userData['short_id'], 
        userData['full_name'], 
        userData['nickname'], 
        'Member', 
        userData['qr_token']
      ]);

      await tx.execute('''
        INSERT INTO members (id, status, started_date, valid_until, membership_type_id, coach_id)
        VALUES (?, ?, ?, ?, ?, ?)
      ''', [
        userData['id'], 
        'Active', 
        userData['started_date'],
        userData['valid_until'],
        userData['membership_type_id'], 
        userData['coach_id']
      ]);
    });
  }

  /// Generates the necessary fields after the user fills in the fields
  /// from the registration form
  static Future<void> generateMemberCredentials(Map<String, dynamic> userData) async {
    userData['id'] = const Uuid().v4(); // Generate UUID 
    userData['short_id'] = await generateUniqueShortId();
    userData['qr_token'] = await generateUniqueQrToken();

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

    if (userData['short_id'].isEmpty) {
      throw Exception('[CREDENTIAL GENERATOR]: ShortId was not generated successfully');
    }

    if (userData['qr_token'].isEmpty) {
      throw Exception('[CREDENTIAL GENERATOR]: QrToken was not generated successfully');
    }
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
