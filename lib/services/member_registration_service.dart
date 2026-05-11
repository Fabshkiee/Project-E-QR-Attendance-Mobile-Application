import 'dart:math';

import 'package:flutter/material.dart';
import 'package:project_e_qr_app/main.dart';
import 'package:uuid/uuid.dart';

/// Handles credential generation, staff qr validation, 
/// and write to local db operations for new users
class MemberRegistrationService {
  MemberRegistrationService._();

  /// Writes the new member to local db
  static Future<void> registerNewUser(Map<String, dynamic> userData) async {
    
  }

  /// Generates the necessary fields after the user fills in the fields
  /// from the registration form
  static Future<void> generateMemberCredentials(Map<String, dynamic> userData) async {
    try {
      userData['id'] = const Uuid().v4(); // Generate UUID 
      userData['short_id'] = await generateUniqueShortId();
      userData['qr_token'] = await generateUniqueQrToken();

      if (userData['short_id'].isEmpty) {
        throw Exception('[CREDENTIAL GENERATOR]: ShortId was not generated successfully');
      }
      if (userData['qr_token'].isEmpty) {
        throw Exception('[CREDENTIAL GENERATOR]: QrToken was not generated successfully');
      }
    } catch (e) {
      debugPrint('[CREDENTIAL GENERATOR]: Error - $e');
    }
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
      final result = await db.getOptional(
        'SELECT 1 FROM $tableName WHERE $attribute = ? LIMIT 1',
        [candidate],
      );

      final alreadyExists = result != null;
      if (!alreadyExists) {
        return candidate;
      }
    }

    return candidate;
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

  /// Test function to write dummy user into database. 
  /// In order to validate if reading/writing successfully works.
  /// 
  /// Note: Delete before production.
  static Future<bool> createDummy() async {
    try {
      final id = Uuid().v4();
      final shortId = await generateUniqueShortId();
      final qrToken = await generateUniqueQrToken();

      debugPrint('[CREATE DUMMY]: $shortId');
      debugPrint('[CREATE DUMMY]: $qrToken');

      if (shortId.isEmpty) {
        throw Exception('[CREDENTIAL GENERATION]: ShortId was not generated successfully');
      }
      if (qrToken.isEmpty) {
        throw Exception('[CREDENTIAL GENERATION]: QrToken was not generated successfully');
      }

      await db.writeTransaction((tx) async {
        await tx.execute('''
          INSERT INTO users (id, short_id, full_name, nickname, role, qr_token)
          VALUES (?, ?, ?, ?, ?, ?)
        ''', [id, shortId, 'John', 'J', 'Member', qrToken]);

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
        ''', [id, 'Active', today.toIso8601String(), until.toIso8601String(), 1]);
      });

      return true;
    } catch (e) {
      debugPrint('[DUMMY USER CREATION]: Registration Failed - $e');
      return false;
    }
  }
}
