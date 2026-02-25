import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

/// Recent check-ins panel with avatars and timestamps.
class DashboardRecentMembers extends StatelessWidget {
  const DashboardRecentMembers({super.key, required this.visitors});

  final List<CurrentVisitorResponse> visitors;

  @override
  Widget build(BuildContext context) {
    final sorted = List<CurrentVisitorResponse>.from(visitors)
      ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
    final recent = sorted.take(8).toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Nedavne prijave', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.lg),
          if (recent.isEmpty)
            SizedBox(
              height: 120,
              child: Center(
                child: Text('Nema prijavljenih korisnika',
                    style: AppTextStyles.bodyMd),
              ),
            )
          else
            for (int i = 0; i < recent.length; i++)
              _CheckInRow(
                visitor: recent[i],
                showBorder: i < recent.length - 1,
              ),
        ],
      ),
    );
  }
}

class _CheckInRow extends StatelessWidget {
  const _CheckInRow({required this.visitor, required this.showBorder});

  final CurrentVisitorResponse visitor;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(visitor.fullName);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: showBorder
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
            )
          : null,
      child: Row(
        children: [
          AvatarWidget(initials: initials, size: 32),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              visitor.fullName,
              style: AppTextStyles.bodyBold,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Text(visitor.checkInTimeFormatted, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  static String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }
}
