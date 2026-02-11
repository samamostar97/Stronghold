class AppointmentDateUtils {
  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static DateTime parse(String value) {
    final parsed = DateTime.parse(value);
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  static DateTime normalizeLocalDate(DateTime date) {
    final local = date.isUtc ? date.toLocal() : date;
    return DateTime(local.year, local.month, local.day);
  }

  static DateTime normalizeLocalHour(DateTime date) {
    final local = date.isUtc ? date.toLocal() : date;
    return DateTime(local.year, local.month, local.day, local.hour);
  }

  static String toApiDate(DateTime date) {
    final local = normalizeLocalDate(date);
    final month = _twoDigits(local.month);
    final day = _twoDigits(local.day);
    return '${local.year}-$month-$day';
  }

  static String toApiDateTime(DateTime date) {
    final local = normalizeLocalHour(date);
    final month = _twoDigits(local.month);
    final day = _twoDigits(local.day);
    final hour = _twoDigits(local.hour);
    return '${local.year}-$month-${day}T$hour:00:00';
  }
}
