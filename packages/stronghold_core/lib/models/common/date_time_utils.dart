class DateTimeUtils {
  static final RegExp _hasZoneSuffix = RegExp(r'(Z|[+-]\d{2}:\d{2})$');

  static DateTime parseApiDateTime(String value) {
    final parsed = DateTime.parse(value);

    // API datetime without explicit timezone is treated as UTC by contract.
    final hasExplicitZone = _hasZoneSuffix.hasMatch(value);
    if (!hasExplicitZone && value.contains('T')) {
      return DateTime.utc(
        parsed.year,
        parsed.month,
        parsed.day,
        parsed.hour,
        parsed.minute,
        parsed.second,
        parsed.millisecond,
        parsed.microsecond,
      ).toLocal();
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
}
