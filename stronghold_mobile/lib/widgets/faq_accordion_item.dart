import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'package:stronghold_core/stronghold_core.dart';

class FaqAccordionItem extends StatelessWidget {
  final FaqResponse faq;

  const FaqAccordionItem({super.key, required this.faq});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
          childrenPadding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textMuted,
          title:
              Text(faq.question, style: AppTextStyles.bodyBold),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(faq.answer,
                  style:
                      AppTextStyles.bodyMd.copyWith(height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}
