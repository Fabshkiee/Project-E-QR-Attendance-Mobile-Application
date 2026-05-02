import 'dart:math';

import 'package:project_e_qr_app/main.dart';

/// Handles credential generation, staff qr validation, 
/// and write to local db operations for new users
class MemberRegistrationService {

  /// Executes the verification of staff qr, credential generation, and
  /// writing to local db on success
  static Future<void> registerNewUser() async {}
  
  /// Queries the staff table to check if it exists
  static Future<bool> verifyStaffQR(String parsedQR) async {
    return false;
  }

  static void generateMemberCredentials(Map<String, dynamic> user) {
    // Generate shortId
    // Generate UUID
    // Generate QR Token
  }

  /// Generates a unique `shortId` by checking against the local db and recomputes when necessary.
  /// Empty string means it cannot generate a unique id after N attempts. This is likely because the database is full.
  /// 
  /// Random ID generation strategy: 2 digits of time + 2 digits of a random number
  /// Spreads out the likelihood of encountering a collision ensuring speed. 
  static Future<String> generateUniqueShortId() async {
    int attempts = 0;    // Safety counter to prevent infinite loops if the DB is full
    int maxAttempts = 100;
    String candidateId = '';

    while (attempts < maxAttempts) {
      attempts++;

      final timePart = (DateTime.now().millisecondsSinceEpoch % 100).toString().padLeft(2, '0'); // 1. Get last 2 digits of milliseconds
      final randomPart = Random().nextInt(100).toString().padLeft(2, '0'); // 2. Get 2 digits of randomness
      candidateId = 'L$timePart$randomPart';
      
      // 3. Check the db
      final results = await db.execute(
        'SELECT 1 FROM users WHERE shortId = ? LIMIT 1',
        [candidateId],
      );

      if (results.isEmpty) {
        return candidateId;
      }
    }

    return candidateId;
  }
}