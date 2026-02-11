import 'package:stronghold_core/stronghold_core.dart';

class FormValidators {
  static String? required(String? value, {String message = 'Obavezno polje'}) {
    if (ValidationUtils.isBlank(value)) {
      return message;
    }

    return null;
  }

  static String? stringLength(
    String? value, {
    required int min,
    required int max,
    required String requiredMessage,
    required String minMessage,
    required String maxMessage,
  }) {
    if (ValidationUtils.isBlank(value)) {
      return requiredMessage;
    }

    if (!ValidationUtils.hasMinLength(value, min)) {
      return minMessage;
    }

    if (!ValidationUtils.hasMaxLength(value, max)) {
      return maxMessage;
    }

    return null;
  }

  static String? email(
    String? value, {
    String requiredMessage = 'Molimo unesite email',
  }) {
    if (ValidationUtils.isBlank(value)) {
      return requiredMessage;
    }

    final normalized = ValidationUtils.normalize(value);
    if (!ValidationUtils.hasMinLength(normalized, 5, trim: false)) {
      return 'Email je prekratak';
    }

    if (!ValidationUtils.hasMaxLength(normalized, 255, trim: false)) {
      return 'Email moze imati maksimalno 255 karaktera';
    }

    if (!ValidationUtils.isValidEmail(normalized)) {
      return 'Unesite ispravnu email adresu';
    }

    return null;
  }

  static String? phoneBiH(
    String? value, {
    String requiredMessage = 'Molimo unesite broj telefona',
  }) {
    if (ValidationUtils.isBlank(value)) {
      return requiredMessage;
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

  static String? password(
    String? value, {
    String requiredMessage = 'Molimo unesite lozinku',
    int minLength = 6,
    int maxLength = 100,
  }) {
    if (value == null || value.isEmpty) {
      return requiredMessage;
    }

    if (!ValidationUtils.hasMinLength(value, minLength, trim: false)) {
      return 'Lozinka mora imati najmanje $minLength karaktera';
    }

    if (!ValidationUtils.hasMaxLength(value, maxLength, trim: false)) {
      return 'Lozinka moze imati maksimalno $maxLength karaktera';
    }

    return null;
  }

  static String? confirmPassword(
    String? value,
    String originalPassword, {
    String requiredMessage = 'Molimo potvrdite lozinku',
    String mismatchMessage = 'Lozinke se ne podudaraju',
  }) {
    if (value == null || value.isEmpty) {
      return requiredMessage;
    }

    if (value != originalPassword) {
      return mismatchMessage;
    }

    return null;
  }

  static String? verificationCode(
    String? value, {
    int digits = 6,
    String requiredMessage = 'Molimo unesite kod',
  }) {
    if (ValidationUtils.isBlank(value)) {
      return requiredMessage;
    }

    final normalized = ValidationUtils.normalize(value);
    if (!ValidationUtils.isDigitsOnly(normalized)) {
      return 'Kod mora sadrzavati samo cifre';
    }

    if (normalized.length != digits) {
      return 'Kod mora imati $digits cifara';
    }

    return null;
  }

  static String? requiredMaxLength(
    String? value, {
    required int maxLength,
    required String requiredMessage,
    required String maxLengthMessage,
  }) {
    if (ValidationUtils.isBlank(value)) {
      return requiredMessage;
    }

    if (!ValidationUtils.hasMaxLength(value, maxLength)) {
      return maxLengthMessage;
    }

    return null;
  }
}
