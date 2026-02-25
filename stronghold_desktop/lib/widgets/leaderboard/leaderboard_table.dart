import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../shared/data_table_widgets.dart';

class LeaderboardTable extends StatelessWidget {
  const LeaderboardTable({super.key, required this.entries});
  final List<LeaderboardEntryResponse> entries;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(children: [
          TableHeaderCell(text: 'Rang', flex: 1),
          TableHeaderCell(text: 'Korisnik', flex: 4),
          TableHeaderCell(text: 'Level', flex: 2),
          TableHeaderCell(text: 'XP', flex: 2, alignRight: true),
        ]),
      ),
      itemCount: entries.length,
      itemBuilder: (context, i) => _LeaderboardRow(
        entry: entries[i],
        index: i,
        isLast: i == entries.length - 1,
      ),
    );
  }
}

class _LeaderboardRow extends StatefulWidget {
  const _LeaderboardRow({
    required this.entry,
    required this.index,
    required this.isLast,
  });
  final LeaderboardEntryResponse entry;
  final int index;
  final bool isLast;

  @override
  State<_LeaderboardRow> createState() => _LeaderboardRowState();
}

class _LeaderboardRowState extends State<_LeaderboardRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _rankColor(int rank) => switch (rank) {
        1 => AppColors.warning,
        2 => AppColors.textSecondary,
        3 => AppColors.orange,
        _ => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    final color = _rankColor(widget.entry.rank);
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: HoverableTableRow(
          index: widget.index,
          isLast: widget.isLast,
          child: Row(children: [
            Expanded(
              flex: 1,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (widget.entry.rank <= 3) ...[
                    Icon(LucideIcons.trophy, color: color, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text('#${widget.entry.rank}',
                      style: AppTextStyles.bodyBold
                          .copyWith(color: color, fontSize: 16)),
                ]),
              ),
            ),
            Expanded(
              flex: 4,
              child: Row(children: [
                _Avatar(entry: widget.entry, rankColor: color),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(widget.entry.fullName,
                      style: AppTextStyles.bodyBold,
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),
            Expanded(
              flex: 2,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.accentDim,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
                  ),
                  child: Text('Level ${widget.entry.level}',
                      style: AppTextStyles.bodyBold
                          .copyWith(color: AppColors.accent)),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text('${widget.entry.currentXP} XP',
                  style: AppTextStyles.bodyBold, textAlign: TextAlign.right),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.entry, required this.rankColor});
  final LeaderboardEntryResponse entry;
  final Color rankColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: entry.rank <= 3 ? rankColor : AppColors.border,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: entry.profileImageUrl != null &&
                entry.profileImageUrl!.isNotEmpty
            ? Image.network(
                ApiConfig.imageUrl(entry.profileImageUrl!),
                fit: BoxFit.cover,
                errorBuilder: (_, e, s) => _initials(),
              )
            : _initials(),
      ),
    );
  }

  Widget _initials() {
    final parts = entry.fullName.split(' ');
    String init = parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
    if (parts.length > 1) init += parts[1][0].toUpperCase();
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      child: Text(init,
          style: AppTextStyles.bodySm
              .copyWith(color: AppColors.accent, fontWeight: FontWeight.w700)),
    );
  }
}
