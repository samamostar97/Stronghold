import 'package:flutter/material.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';
import '../shared/data_table_widgets.dart';
import '../shared/small_button.dart';

/// Users data table with avatar, name, email, phone, and actions.
class UsersTable extends StatelessWidget {
  const UsersTable({
    super.key,
    required this.users,
    required this.onEdit,
    required this.onDelete,
    this.onDetails,
  });

  final List<UserResponse> users;
  final ValueChanged<UserResponse> onEdit;
  final ValueChanged<UserResponse> onDelete;
  final ValueChanged<UserResponse>? onDetails;

  @override
  Widget build(BuildContext context) {
    return DataTableContainer(
      header: const TableHeader(
        child: Row(
          children: [
            TableHeaderCell(text: '', flex: 1),
            TableHeaderCell(text: 'Ime i prezime', flex: 3),
            TableHeaderCell(text: 'Korisnicko ime', flex: 2),
            TableHeaderCell(text: 'Email', flex: 3),
            TableHeaderCell(text: 'Telefon', flex: 2),
            TableHeaderCell(text: 'Akcije', flex: 3, alignRight: true),
          ],
        ),
      ),
      itemCount: users.length,
      itemBuilder: (context, i) => _UserRow(
        user: users[i],
        index: i,
        isLast: i == users.length - 1,
        onEdit: () => onEdit(users[i]),
        onDelete: () => onDelete(users[i]),
        onDetails: onDetails != null ? () => onDetails!(users[i]) : null,
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.index,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
    this.onDetails,
  });

  final UserResponse user;
  final int index;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(user.firstName, user.lastName);

    return HoverableTableRow(
      isLast: isLast,
      index: index,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: user.profileImageUrl != null
                  ? Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        child: Image.network(
                          ApiConfig.imageUrl(user.profileImageUrl!),
                          fit: BoxFit.cover,
                          width: 32,
                          height: 32,
                          errorBuilder: (_, _, _) =>
                              AvatarWidget(initials: initials, size: 32),
                        ),
                      ),
                    )
                  : AvatarWidget(initials: initials, size: 32),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${user.firstName} ${user.lastName}',
              style: AppTextStyles.bodyBold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TableDataCell(text: user.username, flex: 2),
          TableDataCell(text: user.email, flex: 3),
          TableDataCell(text: user.phoneNumber, flex: 2),
          TableActionCell(
            flex: 3,
            children: [
              if (onDetails != null)
                SmallButton(
                    text: 'Detalji',
                    color: AppColors.primary,
                    onTap: onDetails!),
              if (onDetails != null)
                const SizedBox(width: AppSpacing.sm),
              SmallButton(
                  text: 'Izmijeni',
                  color: AppColors.secondary,
                  onTap: onEdit),
              const SizedBox(width: AppSpacing.sm),
              SmallButton(
                  text: 'Obrisi',
                  color: AppColors.error,
                  onTap: onDelete),
            ],
          ),
        ],
      ),
    );
  }

  static String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    return '$f$l'.toUpperCase();
  }
}
