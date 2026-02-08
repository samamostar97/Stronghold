import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    blurRadius: 12,
                  ),
                ]
              : [],
        ),
        child: TextField(
          controller: widget.controller,
          onSubmitted: widget.onSubmitted,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
            filled: true,
            fillColor: AppColors.panel,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.accent.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: _focused ? AppColors.accent : AppColors.muted,
              size: 20,
            ),
            suffixIcon: _hasText
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onSubmitted('');
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
