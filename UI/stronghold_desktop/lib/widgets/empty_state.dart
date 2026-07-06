import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Prazno stanje liste - prigusena ikonica u tinted krugu + poruka.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppTheme.navyTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: AppTheme.navy),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
