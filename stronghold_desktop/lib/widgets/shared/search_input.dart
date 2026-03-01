import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

class SearchInput extends StatefulWidget {
  const SearchInput({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.hintText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final String hintText;

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  bool _focused = false;
  bool _hasText = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () {
      widget.onSubmitted(widget.controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          boxShadow: _focused ? AppColors.cyanGlow : const <BoxShadow>[],
        ),
        child: TextField(
          controller: widget.controller,
          onSubmitted: widget.onSubmitted,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.bodySecondary,
            prefixIcon: Icon(
              LucideIcons.search,
              size: 16,
              color: _focused ? AppColors.primary : AppColors.textMuted,
            ),
            suffixIcon: _hasText
                ? IconButton(
                    onPressed: () {
                      widget.controller.clear();
                      widget.onSubmitted('');
                    },
                    icon: const Icon(
                      LucideIcons.x,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                  )
                : null,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ),
    );
  }
}
