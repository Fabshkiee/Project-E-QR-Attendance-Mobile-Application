import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConnector extends PowerSyncBackendConnector {
  final SupabaseClient supabase;

  SupabaseConnector(this.supabase);

  /// Fetch credentials from Supabase to authenticate with PowerSync.
  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final session = supabase.auth.currentSession;
    if (session == null) {
      // Not logged in
      return null;
    }

    final token = session.accessToken;
    final powerSyncUrl = dotenv.env['POWERSYNC_URL'] ?? '';

    return PowerSyncCredentials(
      endpoint: powerSyncUrl,
      token: token,
    );
  }

  /// Upload local offline changes to Supabase.
  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final transaction = await database.getNextCrudTransaction();

    if (transaction == null) {
      return;
    }

    try {
      for (final op in transaction.crud) {
        final table = op.table;
        if (op.op == UpdateType.put) {
          final data = Map<String, dynamic>.of(op.opData!);
          data['id'] = op.id;

          // Normalize legacy local values so old queued rows can sync.
          if (table == 'attendance_logs') {
            final rawStatus = data['status_at_scan'];
            if (rawStatus is String) {
              final lowered = rawStatus.toLowerCase();
              if (lowered == 'member') {
                data['status_at_scan'] = 'Active';
              } else if (lowered == 'staff' || lowered == 'admin') {
                data['status_at_scan'] = null;
              } else if (lowered == 'active') {
                data['status_at_scan'] = 'Active';
              } else if (lowered == 'inactive') {
                data['status_at_scan'] = 'Inactive';
              } else if (lowered == 'expired') {
                data['status_at_scan'] = 'Expired';
              } else {
                // Unknown enum value from legacy row - prefer null over sync failure.
                data['status_at_scan'] = null;
              }
            }
          }

          await supabase.from(table).upsert(data);
        } else if (op.op == UpdateType.patch) {
          await supabase.from(table).update(op.opData!).eq('id', op.id);
        } else if (op.op == UpdateType.delete) {
          await supabase.from(table).delete().eq('id', op.id);
        }
      }

      // Mark the transaction as complete
      await transaction.complete();
    } catch (e, stacktrace) {
      print('=============================================');
      print('❌ SUPABASE UPLOAD REJECTED YOUR SQLITE ROW!');
      print('Exact Error: $e');
      print('Failed transaction payload: ${transaction.crud}');
      print('Stacktrace: $stacktrace');
      print('=============================================');
      // If there's an error, we don't complete the transaction
      rethrow;
    }
  }
}
