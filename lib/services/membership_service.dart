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
}
