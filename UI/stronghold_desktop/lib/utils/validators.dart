import 'package:flutter/services.dart';

/// Zajednicka validacija unosa - telefon u formatu 0XX-XXX-XXX (ili 4 cifre na kraju).
class Validators {
  static final RegExp phoneRegex = RegExp(r'^0\d{2}-\d{3}-\d{3,4}$');

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Unesite broj telefona.';
    }
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Unesite broj telefona u formatu: 061-123-456';
    }
    return null;
  }
}

/// Pusta samo cifre i automatski ubacuje crtice nakon 3. i 6. cifre (max 10 cifara).
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write('-');
      }
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
