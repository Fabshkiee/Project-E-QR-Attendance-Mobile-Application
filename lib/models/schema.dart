import 'package:powersync/powersync.dart';

const schema = Schema([
  Table('attendance_logs', [
    Column.text('user_id'),
    Column.text('check_in_time'),
    Column.text('status_at_scan'),
    Column.text('created_at')
  ]),
  Table('members', [
    Column.text('status'),
    Column.text('started_date'),
    Column.text('valid_until'),
    Column.integer('membership_type_id'),
    Column.text('coach_id')
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
  ])
]);
