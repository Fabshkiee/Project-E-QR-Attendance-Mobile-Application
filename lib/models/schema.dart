import 'package:powersync/powersync.dart';

const schema = Schema([
  Table('users', [
    Column.text('auth_user_id'),
    Column.text('short_id'),
    Column.text('full_name'),
    Column.text('nickname'),
    Column.text('contact_number'),
    Column.text('role'),
    Column.text('qr_token'),
    Column.text('created_at'),
    Column.text('updated_at')
  ]),
  Table('members', [
    Column.text('status'),
    Column.text('started_date'),
    Column.text('valid_until'),
    Column.integer('membership_type_id'),
    Column.text('coach_id'),
    Column.integer('is_discounted')
  ]),
  Table('staff', [
    Column.text('subrole'),
    Column.text('last_active')
  ]),
  Table('membership_types', [
    Column.text('name'),
    Column.text('monthly_fee'),
    Column.text('student_fee'),
    Column.text('created_at')
  ]),
  // NOTE: attendance_logs is NOT included here.
  // It is created manually in openDatabase() as a local-only fallback table.
  // Writing directly to Supabase via AttendanceRemoteService avoids the
  // sync feedback loop that caused 300k+ realtime.list_changes calls.
]);