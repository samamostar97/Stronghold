import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ActivityFeed extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const ActivityFeed({super.key, required this.activities});

  IconData _iconForType(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'appointment':
        return Icons.calendar_today_outlined;
      case 'registration':
        return Icons.person_add_outlined;
      case 'review':
        return Icons.star_outline_rounded;
      default:
        return Icons.info_outline;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'order':
        return AppColors.primary;
      case 'appointment':
        return AppColors.info;
      case 'registration':
        return AppColors.success;
      case 'review':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _timeAgo(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final diff = DateTime.now().toUtc().difference(date);

    if (diff.inMinutes < 1) return 'Upravo';
    if (diff.inMinutes < 60) return 'Prije ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Prije ${diff.inHours}h';
    if (diff.inDays < 7) return 'Prije ${diff.inDays}d';
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Nema nedavnih aktivnosti',
            style: AppTextStyles.bodySmall,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      separatorBuilder: (_, _) => Divider(
        color: Colors.white.withValues(alpha: 0.04),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final item = activities[index];
        final type = item['type'] as String? ?? '';
        final message = item['message'] as String? ?? '';
        final createdAt = item['createdAt'] as String? ?? '';
        final color = _colorForType(type);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconForType(type), color: color, size: 16),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _timeAgo(createdAt),
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}
