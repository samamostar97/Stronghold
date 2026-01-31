import 'package:flutter/material.dart';

import 'gradient_button.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GradientButton(text: '\u2190 Nazad', onTap: onTap),
    );
  }
}
