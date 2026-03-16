import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9+]'), '');

    final buffer = StringBuffer();
    var digitIndex = 0;

    for (var i = 0; i < digits.length; i++) {
      if (digits[i] == '+' && i == 0) {
        buffer.write('+');
        continue;
      }

      if (digitIndex == 3 || digitIndex == 6) {
        buffer.write('-');
      }

      buffer.write(digits[i]);
      digitIndex++;

      if (digitIndex >= 9) break;
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
