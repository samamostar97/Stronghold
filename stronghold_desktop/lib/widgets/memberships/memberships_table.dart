import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/membership_provider.dart';
import '../shared/data_table_widgets.dart';
import '../shared/small_button.dart';

class MembershipsTable extends StatelessWidget {
  const MembershipsTable({
    super.key,
    required this.users,
    required this.onViewPayments,
    required this.onAddPayment,
    required this.onRevokeMembership,
  });

  final List<UserResponse> users;
  final ValueChanged<UserResponse> onViewPayments;
  final ValueChanged<UserResponse> onAddPayment;
  final ValueChanged<UserResponse> onRevokeMembership;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(children: [
          TableHeaderCell(text: 'Korisnicko ime', flex: 2),
          TableHeaderCell(text: 'Ime', flex: 2),
          TableHeaderCell(text: 'Prezime', flex: 2),
          TableHeaderCell(text: 'Email', flex: 3),
          TableHeaderCell(text: 'Akcije', flex: 4, alignRight: true),
        ]),
      ),
      itemCount: users.length,
      itemBuilder: (context, i) => _MembershipRow(
        user: users[i],
        index: i,
        isLast: i == users.length - 1,
        onViewPayments: () => onViewPayments(users[i]),
        onAddPayment: () => onAddPayment(users[i]),
        onRevokeMembership: () => onRevokeMembership(users[i]),
      ),
    );
  }
}

class _MembershipRow extends ConsumerStatefulWidget {
  const _MembershipRow({
    required this.user,
    required this.index,
    required this.isLast,
    required this.onViewPayments,
    required this.onAddPayment,
    required this.onRevokeMembership,
  });

  final UserResponse user;
  final int index;
  final bool isLast;
  final VoidCallback onViewPayments;
  final VoidCallback onAddPayment;
  final VoidCallback onRevokeMembership;

  @override
  ConsumerState<_MembershipRow> createState() => _MembershipRowState();
}

class _MembershipRowState extends ConsumerState<_MembershipRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final membershipAsync =
        ref.watch(userHasActiveMembershipProvider(widget.user.id));
    final isActive = !membershipAsync.isLoading &&
        (membershipAsync.valueOrNull == true);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: HoverableTableRow(
        index: widget.index,
        isLast: widget.isLast,
        activeAccentColor: isActive ? AppColors.success : null,
        child: Row(children: [
          TableDataCell(text: widget.user.username, flex: 2),
          Expanded(
            flex: 2,
            child: Row(children: [
              if (isActive)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  decoration: const BoxDecoration(
                      color: AppColors.success, shape: BoxShape.circle),
                )
              else if (membershipAsync.isLoading)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  child: const CircularProgressIndicator(
                      strokeWidth: 1.5, color: AppColors.textMuted),
                ),
              Flexible(
                child: Text(widget.user.firstName,
                    style: AppTextStyles.bodyBold,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ),
            ]),
          ),
          TableDataCell(text: widget.user.lastName, flex: 2),
          TableDataCell(text: widget.user.email, flex: 3),
          Expanded(
            flex: 4,
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _hovered
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              alignment: Alignment.centerRight,
              firstChild: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _ActionCircle(
                    icon: LucideIcons.eye,
                    color: AppColors.secondary,
                    tooltip: 'Pregled uplata',
                    onTap: widget.onViewPayments,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _ActionCircle(
                    icon: LucideIcons.plus,
                    color: AppColors.primary,
                    tooltip: 'Dodaj uplatu',
                    onTap: widget.onAddPayment,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _ActionCircle(
                    icon: LucideIcons.ban,
                    color: AppColors.error,
                    tooltip: 'Ukini clanarinu',
                    onTap: widget.onRevokeMembership,
                  ),
                ],
              ),
              secondChild: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SmallButton(
                        text: 'Pregled uplata',
                        color: AppColors.secondary,
                        onTap: widget.onViewPayments),
                    const SizedBox(width: AppSpacing.sm),
                    SmallButton(
                        text: 'Dodaj uplatu',
                        color: AppColors.primary,
                        onTap: widget.onAddPayment),
                    const SizedBox(width: AppSpacing.sm),
                    SmallButton(
                        text: 'Ukini clanarinu',
                        color: AppColors.error,
                        onTap: widget.onRevokeMembership),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ActionCircle extends StatefulWidget {
  const _ActionCircle({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_ActionCircle> createState() => _ActionCircleState();
}

class _ActionCircleState extends State<_ActionCircle> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: _hover ? 0.2 : 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.color.withValues(alpha: _hover ? 0.5 : 0.25),
              ),
            ),
            child: Icon(widget.icon, size: 14, color: widget.color),
          ),
        ),
      ),
    );
  }
}
