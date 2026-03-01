import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

class SettingsTabScaffold extends StatelessWidget {
  const SettingsTabScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.addLabel,
    required this.onAdd,
    required this.child,
  });

  final String title;
  final String subtitle;
  final String addLabel;
  final VoidCallback onAdd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            0,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 820;
              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _titleBlock(),
                    const SizedBox(height: AppSpacing.md),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _SettingsAddButton(label: addLabel, onTap: onAdd),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _titleBlock()),
                  const SizedBox(width: AppSpacing.md),
                  _SettingsAddButton(label: addLabel, onTap: onAdd),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(child: child),
      ],
    );
  }

  Widget _titleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.sectionTitle),
        const SizedBox(height: 2),
        Text(subtitle, style: AppTextStyles.caption),
      ],
    );
  }
}

class _SettingsAddButton extends StatefulWidget {
  const _SettingsAddButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_SettingsAddButton> createState() => _SettingsAddButtonState();
}

class _SettingsAddButtonState extends State<_SettingsAddButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFF2F52D9) : AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: _hover ? const Color(0xFF2F52D9) : AppColors.primary,
            ),
            boxShadow: AppColors.buttonShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.plus, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: AppTextStyles.badge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsStatePane extends StatelessWidget {
  const SettingsStatePane({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.cardRadius,
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: AppSpacing.buttonRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, size: 20, color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: AppTextStyles.cardTitle),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              _SettingsAddButton(label: actionLabel, onTap: onAction),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsSkeletonWrap extends StatelessWidget {
  const SettingsSkeletonWrap({
    super.key,
    required this.itemCount,
    required this.itemWidth,
    required this.itemHeight,
    this.spacing = AppSpacing.lg,
    this.runSpacing = AppSpacing.lg,
  });

  final int itemCount;
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: List.generate(
          itemCount,
          (_) =>
              Container(
                    width: itemWidth,
                    height: itemHeight,
                    decoration: BoxDecoration(
                      color: AppColors.shimmer,
                      borderRadius: AppSpacing.cardRadius,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: const Duration(milliseconds: 1200),
                    color: AppColors.shimmerHighlight,
                  ),
        ),
      ),
    );
  }
}

class SettingsSkeletonList extends StatelessWidget {
  const SettingsSkeletonList({
    super.key,
    required this.itemCount,
    required this.itemHeight,
  });

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: itemCount,
      separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) =>
          Container(
                height: itemHeight,
                decoration: BoxDecoration(
                  color: AppColors.shimmer,
                  borderRadius: AppSpacing.panelRadius,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: const Duration(milliseconds: 1200),
                color: AppColors.shimmerHighlight,
              ),
    );
  }
}
