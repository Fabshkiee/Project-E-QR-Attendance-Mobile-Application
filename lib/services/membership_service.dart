import 'package:project_e_qr_app/models/membership_type.dart';
import 'package:project_e_qr_app/main.dart';

class MembershipService {
  static Future<List<MembershipType>> fetchMembershipTypes() async {
    try {
      final rows = await db.getAll(
        'SELECT id, name, monthly_fee, student_fee FROM membership_types ORDER by name',
      );

      return rows
          .map((row) => MembershipType.fromJson(row))
          .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Fetches coaches from the local PowerSync DB.
  /// Returns a list of maps with 'id' and 'display_name' keys.
  static Future<List<Map<String, dynamic>>> fetchCoaches() async {
    try {
      final rows = await db.getAll('''
        SELECT u.id,
               TRIM(COALESCE(u.first_name, '') || ' ' || COALESCE(u.last_name, '')) AS display_name
        FROM users u
        JOIN staff s ON s.id = u.id
        WHERE s.subrole = 'Coach'
        ORDER BY u.first_name
      ''');

      return rows
          .where((r) => (r['id'] ?? '').toString().isNotEmpty)
          .map((r) => {
                'id': r['id'].toString(),
                'display_name': (r['display_name'] ?? 'Coach').toString().trim(),
              })
          .toList();
    } catch (_) {
      return [];
    }
  }
}
