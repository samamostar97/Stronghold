import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

class SmallButton extends StatefulWidget {
  const SmallButton({
    super.key,
    required this.text,
    required this.color,
    required this.onTap,
  });

  final String text;
  final Color color;
  final VoidCallback onTap;

  @override
  State<SmallButton> createState() => _SmallButtonState();
}

class _SmallButtonState extends State<SmallButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isPrimaryLike = widget.color == AppColors.primary;
    final bg = isPrimaryLike
        ? (_hover ? const Color(0xFF2F52D9) : AppColors.primary)
        : (_hover
              ? widget.color.withValues(alpha: 0.16)
              : widget.color.withValues(alpha: 0.11));

    final borderColor = isPrimaryLike
        ? (_hover ? const Color(0xFF2F52D9) : AppColors.primary)
        : widget.color.withValues(alpha: 0.35);

    final textColor = isPrimaryLike ? Colors.white : widget.color;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            widget.text,
            style: AppTextStyles.badge.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
