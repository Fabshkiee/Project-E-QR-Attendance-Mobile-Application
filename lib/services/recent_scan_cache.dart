import 'dart:collection';

/// In-memory cache for detecting duplicate scans within a cooldown window.
/// Avoids querying attendance_logs from the database, which was the
/// primary driver of the realtime.list_changes feedback loop.
class RecentScanCache {
  final HashMap<String, DateTime> _cache = HashMap();
  final Duration cooldown;

  RecentScanCache({this.cooldown = const Duration(seconds: 5)});

  /// Returns true if the user was scanned within the cooldown window.
  bool isDuplicate(String userId) {
    final last = _cache[userId];
    if (last == null) return false;
    return DateTime.now().difference(last) < cooldown;
  }

  /// Records a scan for the given user.
  void recordScan(String userId, [DateTime? time]) {
    _cache[userId] = time ?? DateTime.now();
  }

  /// Removes expired entries to prevent unbounded memory growth.
  void cleanup() {
    final cutoff = DateTime.now().subtract(cooldown);
    _cache.removeWhere((_, time) => time.isBefore(cutoff));
  }
}