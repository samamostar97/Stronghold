/// Reusable form validators matching backend DTO validation rules
class Validators {
  /// Required field validation
  static String? required(String? value, [String message = 'Obavezno polje']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  /// String length validation (min and max)
  static String? stringLength(
    String? value,
    int min,
    int max, {
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Obavezno polje' : null;
    }

    final normalized = value.trim();
    if (normalized.length < min) {
      return 'Minimalno $min karaktera';
    }

    if (normalized.length > max) {
      return 'Maksimalno $max karaktera';
    }

    return null;
  }

  /// Name validation (2-100 chars)
  static String? name(String? value, {String fieldName = 'Polje'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Obavezno polje';
    }

    if (value.trim().length < 2) {
      return '$fieldName mora imati najmanje 2 karaktera';
    }

    if (value.trim().length > 100) {
      return '$fieldName moze imati maksimalno 100 karaktera';
    }

    return null;
  }

  /// Username validation (3-50 chars)
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Obavezno polje';
    }

    if (value.trim().length < 3) {
      return 'Korisnicko ime mora imati najmanje 3 karaktera';
    }

    if (value.trim().length > 50) {
      return 'Korisnicko ime moze imati maksimalno 50 karaktera';
    }

    return null;
  }

  /// Email validation (5-255 chars, valid format)
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Obavezno polje';
    }

    final normalized = value.trim();
    if (normalized.length < 5) {
      return 'Email je prekratak';
    }

    if (normalized.length > 255) {
      return 'Email moze imati maksimalno 255 karaktera';
    }

    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(normalized)) {
      return 'Neispravan email format';
    }

    return null;
  }

  /// Website validation (optional, 5-100 chars if provided)
  static String? website(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Obavezno polje' : null;
    }

    final normalized = value.trim();
    if (normalized.length < 5) {
      return 'Web stranica je prekratka';
    }

    if (normalized.length > 100) {
      return 'Web stranica moze imati maksimalno 100 karaktera';
    }

    if (!RegExp(
      r'^(https?://)?(www\.)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(/.*)?$',
    ).hasMatch(normalized)) {
      return 'Unesite ispravnu web adresu (npr. www.example.com)';
    }

    return null;
  }

  /// Phone validation (Bosnian format, 9-20 chars)
  static String? phone(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Obavezno polje' : null;
    }

    final normalized = value.trim();
    if (!RegExp(
      r'^(\+387|387|0)?\s?6\d([-\s]?\d){6,7}$',
    ).hasMatch(normalized)) {
      return 'Format: 061 123 456 ili +387 61 123 456';
    }

    if (normalized.replaceAll(RegExp(r'[\s\-]'), '').length < 9) {
      return 'Broj telefona prekratak';
    }

    return null;
  }

  /// Password validation (6-100 chars)
  static String? password(
    String? value, {
    bool required = true,
    int minLength = 6,
  }) {
    if (value == null || value.isEmpty) {
      return required ? 'Obavezno polje' : null;
    }

    if (value.length < minLength) {
      return 'Lozinka mora imati najmanje $minLength karaktera';
    }

    if (value.length > 100) {
      return 'Lozinka moze imati maksimalno 100 karaktera';
    }

    return null;
  }

  /// Price validation (0.01-10000)
  static String? price(String? value, {double min = 0.01, double max = 10000}) {
    if (value == null || value.trim().isEmpty) {
      return 'Obavezno polje';
    }

    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      return 'Neispravan broj';
    }

    if (parsed < min) {
      return 'Minimalna vrijednost je $min';
    }

    if (parsed > max) {
      return 'Maksimalna vrijednost je $max';
    }

    return null;
  }

  /// Description validation (optional by default, 2-1000 chars if provided)
  static String? description(
    String? value, {
    int maxLength = 1000,
    bool required = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Opis je obavezan' : null;
    }

    final normalized = value.trim();
    if (normalized.length < 2) {
      return 'Opis mora imati najmanje 2 karaktera';
    }

    if (normalized.length > maxLength) {
      return 'Opis moze imati maksimalno $maxLength karaktera';
    }

    return null;
  }

  /// Dropdown required validation
  static String? dropdownRequired<T>(
    T? value, [
    String message = 'Obavezno polje',
  ]) {
    if (value == null) {
      return message;
    }

    return null;
  }

  /// Integer range validation
  static String? intRange(String? value, int min, int max) {
    if (value == null || value.trim().isEmpty) {
      return 'Obavezno polje';
    }

    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Neispravan broj';
    }

    if (parsed < min) {
      return 'Minimalna vrijednost je $min';
    }

    if (parsed > max) {
      return 'Maksimalna vrijednost je $max';
    }

    return null;
  }
}
