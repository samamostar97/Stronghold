import 'package:stronghold_core/stronghold_core.dart';

/// Reusable form validators matching backend DTO validation rules
class Validators {
  /// Required field validation
  static String? required(String? value, [String message = 'Obavezno polje']) {
    if (ValidationUtils.isBlank(value)) {
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
    if (ValidationUtils.isBlank(value)) {
      return required ? 'Obavezno polje' : null;
    }

    if (!ValidationUtils.hasMinLength(value, min)) {
      return 'Minimalno $min karaktera';
    }

    if (!ValidationUtils.hasMaxLength(value, max)) {
      return 'Maksimalno $max karaktera';
    }

    return null;
  }

  /// Name validation (2-100 chars)
  static String? name(String? value, {String fieldName = 'Polje'}) {
    if (ValidationUtils.isBlank(value)) {
      return 'Obavezno polje';
    }

    if (!ValidationUtils.hasMinLength(value, 2)) {
      return '$fieldName mora imati najmanje 2 karaktera';
    }

    if (!ValidationUtils.hasMaxLength(value, 100)) {
      return '$fieldName moze imati maksimalno 100 karaktera';
    }

    return null;
  }

  /// Username validation (3-50 chars)
  static String? username(String? value) {
    if (ValidationUtils.isBlank(value)) {
      return 'Obavezno polje';
    }

    if (!ValidationUtils.hasMinLength(value, 3)) {
      return 'Korisnicko ime mora imati najmanje 3 karaktera';
    }

    if (!ValidationUtils.hasMaxLength(value, 50)) {
      return 'Korisnicko ime moze imati maksimalno 50 karaktera';
    }

    return null;
  }

  /// Email validation (5-255 chars, valid format)
  static String? email(String? value) {
    if (ValidationUtils.isBlank(value)) {
      return 'Obavezno polje';
    }

    final normalized = ValidationUtils.normalize(value);
    if (!ValidationUtils.hasMinLength(normalized, 5, trim: false)) {
      return 'Email je prekratak';
    }

    if (!ValidationUtils.hasMaxLength(normalized, 255, trim: false)) {
      return 'Email moze imati maksimalno 255 karaktera';
    }

    if (!ValidationUtils.isValidEmail(normalized)) {
      return 'Neispravan email format';
    }

    return null;
  }

  /// Website validation (optional, 5-100 chars if provided)
  static String? website(String? value, {bool required = false}) {
    if (ValidationUtils.isBlank(value)) {
      return required ? 'Obavezno polje' : null;
    }

    final normalized = ValidationUtils.normalize(value);
    if (!ValidationUtils.hasMinLength(normalized, 5, trim: false)) {
      return 'Web stranica je prekratka';
    }

    if (!ValidationUtils.hasMaxLength(normalized, 100, trim: false)) {
      return 'Web stranica moze imati maksimalno 100 karaktera';
    }

    if (!ValidationUtils.isValidWebsite(normalized)) {
      return 'Unesite ispravnu web adresu (npr. www.example.com)';
    }

    return null;
  }

  /// Phone validation (Bosnian format, 9-20 chars)
  static String? phone(String? value, {bool required = true}) {
    if (ValidationUtils.isBlank(value)) {
      return required ? 'Obavezno polje' : null;
    }

    final normalized = ValidationUtils.normalize(value);
    if (!ValidationUtils.isValidPhone(normalized)) {
      return 'Format: 061 123 456 ili +387 61 123 456';
    }

    if (!ValidationUtils.hasMaxLength(normalized, 20, trim: false)) {
      return 'Broj telefona moze imati maksimalno 20 karaktera';
    }

    if (ValidationUtils.phoneDigitsCount(normalized) < 9) {
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

    if (!ValidationUtils.hasMinLength(value, minLength, trim: false)) {
      return 'Lozinka mora imati najmanje $minLength karaktera';
    }

    if (!ValidationUtils.hasMaxLength(value, 100, trim: false)) {
      return 'Lozinka moze imati maksimalno 100 karaktera';
    }

    return null;
  }

  /// Price validation (0.01-10000)
  static String? price(String? value, {double min = 0.01, double max = 10000}) {
    if (ValidationUtils.isBlank(value)) {
      return 'Obavezno polje';
    }

    final parsed = double.tryParse(value!.replaceAll(',', '.'));
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
    if (ValidationUtils.isBlank(value)) {
      return required ? 'Opis je obavezan' : null;
    }

    final normalized = ValidationUtils.normalize(value);
    if (!ValidationUtils.hasMinLength(normalized, 2, trim: false)) {
      return 'Opis mora imati najmanje 2 karaktera';
    }

    if (!ValidationUtils.hasMaxLength(normalized, maxLength, trim: false)) {
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
    if (ValidationUtils.isBlank(value)) {
      return 'Obavezno polje';
    }

    final parsed = int.tryParse(ValidationUtils.normalize(value));
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
