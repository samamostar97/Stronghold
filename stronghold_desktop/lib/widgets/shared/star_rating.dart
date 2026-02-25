import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';

/// Displays a row of 1–5 stars for a rating value.
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.size = 16});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          final filled = i < rating;
          return Padding(
            padding: EdgeInsets.only(right: i < 4 ? 2 : 0),
            child: Icon(
              LucideIcons.star,
              size: size,
              color: filled ? AppColors.warning : AppColors.textDark,
            ),
          );
        }),
      ),
    );
  }
}
