class ValidationUtils {
  static final RegExp _emailRegex = RegExp(
    r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$',
  );
  static final RegExp _websiteRegex = RegExp(
    r'^(https?://)?(www\.)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(/.*)?$',
  );
  static final RegExp _phoneRegex = RegExp(
    r'^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$',
  );
  static final RegExp _spaceOrHyphenRegex = RegExp(r'[\s\-]');
  static final RegExp _digitsRegex = RegExp(r'^\d+$');

  static String normalize(String? value) {
    return value?.trim() ?? '';
  }

  static bool isBlank(String? value) {
    return normalize(value).isEmpty;
  }

  static bool hasMinLength(String? value, int min, {bool trim = true}) {
    final target = trim ? normalize(value) : (value ?? '');
    return target.length >= min;
  }

  static bool hasMaxLength(String? value, int max, {bool trim = true}) {
    final target = trim ? normalize(value) : (value ?? '');
    return target.length <= max;
  }

  static bool hasLengthInRange(
    String? value,
    int min,
    int max, {
    bool trim = true,
  }) {
    if (min > max) {
      return false;
    }

    final target = trim ? normalize(value) : (value ?? '');
    return target.length >= min && target.length <= max;
  }

  static bool isValidEmail(String value) {
    return _emailRegex.hasMatch(normalize(value));
  }

  static bool isValidWebsite(String value) {
    return _websiteRegex.hasMatch(normalize(value));
  }

  static bool isValidPhone(String value) {
    return _phoneRegex.hasMatch(normalize(value));
  }

  static int phoneDigitsCount(String value) {
    return normalize(value).replaceAll(_spaceOrHyphenRegex, '').length;
  }

  static bool isDigitsOnly(String value) {
    return _digitsRegex.hasMatch(normalize(value));
  }
}
