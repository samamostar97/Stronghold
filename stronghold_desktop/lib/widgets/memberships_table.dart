import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/membership_provider.dart';
import 'data_table_widgets.dart';
import 'small_button.dart';

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

class _MembershipRow extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipAsync =
        ref.watch(userHasActiveMembershipProvider(user.id));
    final isActive = !membershipAsync.isLoading &&
        (membershipAsync.valueOrNull == true);

    return HoverableTableRow(
      index: index,
      isLast: isLast,
      activeAccentColor: isActive ? AppColors.success : null,
      child: Row(children: [
        TableDataCell(text: user.username, flex: 2),
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
              child: Text(user.firstName,
                  style: AppTextStyles.bodyBold,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            ),
          ]),
        ),
        TableDataCell(text: user.lastName, flex: 2),
        TableDataCell(text: user.email, flex: 3, muted: true),
        TableActionCell(flex: 4, children: [
          SmallButton(
              text: 'Pregled uplata',
              color: AppColors.secondary,
              onTap: onViewPayments),
          const SizedBox(width: AppSpacing.sm),
          SmallButton(
              text: 'Dodaj uplatu',
              color: AppColors.primary,
              onTap: onAddPayment),
          const SizedBox(width: AppSpacing.sm),
          SmallButton(
              text: 'Ukini clanarinu',
              color: AppColors.error,
              onTap: onRevokeMembership),
        ]),
      ]),
    );
  }
}
