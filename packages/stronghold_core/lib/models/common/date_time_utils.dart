class DateTimeUtils {
  static DateTime parseApiDateTime(String value) {
    final parsed = DateTime.parse(value);
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  static DateTime toLocal(DateTime value) {
    return value.isUtc ? value.toLocal() : value;
  }

  static DateTime normalizeLocalDate(DateTime value) {
    final local = toLocal(value);
    return DateTime(local.year, local.month, local.day);
  }
}
