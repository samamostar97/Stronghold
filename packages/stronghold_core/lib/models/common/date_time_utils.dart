class DateTimeUtils {
  static final RegExp _hasZoneSuffix = RegExp(r'(Z|[+-]\d{2}:\d{2})$');

  static DateTime parseApiDateTime(String value) {
    final parsed = DateTime.parse(value);

    // API datetime without explicit timezone is already local (Sarajevo time).
    final hasExplicitZone = _hasZoneSuffix.hasMatch(value);
    if (!hasExplicitZone && value.contains('T')) {
      return DateTime(
        parsed.year,
        parsed.month,
        parsed.day,
        parsed.hour,
        parsed.minute,
        parsed.second,
        parsed.millisecond,
        parsed.microsecond,
      );
    }

    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  static DateTime toLocal(DateTime value) {
    return value.isUtc ? value.toLocal() : value;
  }

  static DateTime normalizeLocalDate(DateTime value) {
    final local = toLocal(value);
    return DateTime(local.year, local.month, local.day);
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static String toApiDate(DateTime date) {
    final local = normalizeLocalDate(date);
    return '${local.year}-${_twoDigits(local.month)}-${_twoDigits(local.day)}';
  }

  static String toApiDateTime(DateTime date) {
    final local = toLocal(date);
    final d = DateTime(local.year, local.month, local.day, local.hour);
    return '${d.year}-${_twoDigits(d.month)}-${_twoDigits(d.day)}'
        'T${_twoDigits(d.hour)}:00:00';
  }
}
