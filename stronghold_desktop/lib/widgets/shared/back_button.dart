import 'package:flutter/material.dart';

import 'package:stronghold_core/stronghold_core.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GradientButton.text(text: '\u2190 Nazad', onPressed: onTap),
    );
  }
}
