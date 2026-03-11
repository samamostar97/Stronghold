import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../models/user_response.dart';

class UsersTable extends StatefulWidget {
  final List<UserResponse> users;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<UserResponse>? onEdit;
  final ValueChanged<UserResponse>? onDelete;

  const UsersTable({
    super.key,
    required this.users,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<UsersTable> createState() => _UsersTableState();
}

class _UsersTableState extends State<UsersTable> {
  int? _hoveredRow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Table
        Container(
          decoration: BoxDecoration(
            color: AppColors.sidebar,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    _HeaderCell('ID', width: 50),
                    const SizedBox(width: 44), // Avatar + spacing
                    _HeaderCell('Ime i prezime', flex: 2),
                    _HeaderCell('Username', flex: 1),
                    _HeaderCell('Email', flex: 2),
                    _HeaderCell('Telefon', flex: 1),
                    _HeaderCell('Clanarina', width: 100),
                    _HeaderCell('Level', width: 70),
                    const SizedBox(width: 80), // Actions
                  ],
                ),
              ),
              Divider(
                  color: Colors.white.withValues(alpha: 0.06), height: 1),

              // Rows
              if (widget.users.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text('Nema korisnika', style: AppTextStyles.bodySmall),
                  ),
                )
              else
                ...widget.users.asMap().entries.map((entry) {
                  final index = entry.key;
                  final user = entry.value;
                  final isHovered = _hoveredRow == index;

                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _hoveredRow = index),
                    onExit: (_) => setState(() => _hoveredRow = null),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isHovered
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.transparent,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          // ID
                          SizedBox(
                            width: 50,
                            child: Text(
                              '#${user.id}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                          ),

                          // Avatar
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: _UserAvatar(user: user),
                          ),

                          // Name
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${user.firstName} ${user.lastName}',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Username
                          Expanded(
                            flex: 1,
                            child: Text(
                              user.username,
                              style: AppTextStyles.bodySmall
                                  .copyWith(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Email
                          Expanded(
                            flex: 2,
                            child: Text(
                              user.email,
                              style: AppTextStyles.body.copyWith(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Phone
                          Expanded(
                            flex: 1,
                            child: Text(
                              user.phone ?? '-',
                              style: AppTextStyles.bodySmall
                                  .copyWith(fontSize: 12),
                            ),
                          ),

                          // Membership status
                          SizedBox(
                            width: 100,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '-',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),

                          // Level
                          SizedBox(
                            width: 70,
                            child: Text(
                              'Lv. ${user.level}',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                            ),
                          ),

                          // Actions
                          SizedBox(
                            width: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      widget.onEdit?.call(user),
                                  icon: const Icon(Icons.edit_outlined,
                                      color: AppColors.textSecondary,
                                      size: 16),
                                  tooltip: 'Uredi',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      widget.onDelete?.call(user),
                                  icon: Icon(Icons.delete_outlined,
                                      color: AppColors.error
                                          .withValues(alpha: 0.7),
                                      size: 16),
                                  tooltip: 'Obrisi',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),

        // Pagination
        if (widget.totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: widget.currentPage > 1
                      ? () => widget.onPageChanged(widget.currentPage - 1)
                      : null,
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: widget.currentPage > 1
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(widget.totalPages, (i) {
                  final page = i + 1;
                  final isActive = page == widget.currentPage;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: GestureDetector(
                      onTap: () => widget.onPageChanged(page),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$page',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.currentPage < widget.totalPages
                      ? () => widget.onPageChanged(widget.currentPage + 1)
                      : null,
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: widget.currentPage < widget.totalPages
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final UserResponse user;

  const _UserAvatar({required this.user});

  String get _imageUrl {
    // baseUrl is like http://localhost:5272/api, strip /api for file serving
    final base = ApiConstants.baseUrl.replaceAll('/api', '');
    return '$base${user.profileImageUrl}';
  }

  @override
  Widget build(BuildContext context) {
    if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _imageUrl,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _initialsAvatar(),
        ),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() {
    final initials = user.firstName.isNotEmpty && user.lastName.isNotEmpty
        ? '${user.firstName[0]}${user.lastName[0]}'
        : '?';
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double? width;
  final int? flex;

  const _HeaderCell(this.label, {this.width, this.flex});

  @override
  Widget build(BuildContext context) {
    final child = Text(
      label,
      style: AppTextStyles.label.copyWith(fontSize: 11),
    );

    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return Expanded(flex: flex ?? 1, child: child);
  }
}
