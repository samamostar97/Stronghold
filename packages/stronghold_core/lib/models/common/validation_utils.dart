class ValidationUtils {
  static final RegExp _emailRegex = RegExp(
    r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$',
  );

  static bool isValidEmail(String value) {
    return _emailRegex.hasMatch(value.trim());
  }
}
