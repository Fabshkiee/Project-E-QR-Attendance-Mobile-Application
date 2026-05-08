import 'dart:math';

import 'package:flutter/material.dart';
import 'package:project_e_qr_app/main.dart';
import 'package:project_e_qr_app/services/database_helpers.dart';
import 'package:uuid/uuid.dart';

/// Handles credential generation, staff qr validation, 
/// and write to local db operations for new users
class MemberRegistrationService {
  MemberRegistrationService._();

  /// Executes the verification of staff qr, credential generation, and
  /// writing to local db on success
  static Future<void> registerNewUser() async {}
  
  /// Queries the staff table to check if the token belongs to a staff
  static Future<bool> isStaffQrToken(String qrToken) async {
    final result = await db.getOptional('''
      SELECT 1 FROM users 
      INNER JOIN staff ON staff.id = users.id 
      WHERE users.qr_token = ? 
      LIMIT 1
    ''', [qrToken]);

    return result != null;
  }

  /// Generates the necessary fields after the user fills in the fields
  /// from the registration form
  static Future<void> generateMemberCredentials(Map<String, dynamic> user) async {
    user['id'] = const Uuid().v4(); // Generate UUID 
    user['short_id'] = await generateUniqueShortId();
    user['qr_token'] = await generateUniqueQrToken();
  }

  /// Generates a unique value for [attribute] in [tableName], retrying up to 100 times if a duplicate is found.
  /// Returns an empty string if no unique value could be generated, likely because the table is full.
  /// Throws if [tableName] or [attribute] does not exist in the database.
  static Future<String> _generateUnique(String tableName, String attribute, String Function() generator) async {
    int attempts = 0;
    int maxAttempts = 100;
    String candidate = '';

    while (attempts < maxAttempts) {
      attempts++;
      candidate = generator();
      final alreadyExists = await checkDuplicateAttribute(tableName, attribute, candidate);

      if (!alreadyExists) {
        return candidate;
      }
    }

    return candidate;
  }

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

  /// Test function to write dummy user into database. 
  /// In order to validate if reading/writing successfully works.
  /// 
  /// Note: Delete before production.
  static Future<bool> createDummy() async {
    try {
      final idRow = await db.getOptional('SELECT uuid() as id');
      final newUserId = idRow!['id'] as String;
      final shortId = await generateUniqueShortId();

      if (shortId.isEmpty) {
        throw Exception('ShortId was not generated successfully');
      }

      await db.writeTransaction((tx) async {
        await tx.execute('''
          INSERT INTO users (id, short_id, full_name, nickname, role)
          VALUES (?, ?, ?, ?, ?)
        ''', [newUserId, shortId, 'John', 'J', 'Member']);

        DateTime today = DateTime.now();
        DateTime until = DateTime(
          today.year, 
          today.month + 3, 
          today.day, 
          today.hour, 
          today.minute
        );

        await tx.execute('''
          INSERT INTO members (id, status, started_date, valid_until, membership_type_id)
          VALUES (?, ?, ?, ?, ?)
        ''', [newUserId, 'Active', today.toIso8601String(), until.toIso8601String(), 1]);
      });

      return true;
    } catch (e) {
      debugPrint('[DUMMY USER CREATION]: Registration Failed - $e');
      return false;
    }
  }
}