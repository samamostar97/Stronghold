import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/admin_activity_paged_provider.dart';
import '../widgets/shared/data_table_widgets.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/pagination_controls.dart';
import '../widgets/shared/search_input.dart';
import '../widgets/shared/shimmer_loading.dart';
import '../widgets/shared/small_button.dart';
import '../widgets/shared/success_animation.dart';

class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key});

  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  final _searchController = TextEditingController();
  final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');
  String? _orderBy;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminActivityPagedProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _undoActivity(int id) async {
    try {
      await ref.read(adminActivityPagedProvider.notifier).undo(id);
      if (mounted) {
        showSuccessAnimation(context, message: 'Undo uspjesno izvrsen.');
      }
    } catch (e) {
      if (mounted) {
        showErrorAnimation(
          context,
          message: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminActivityPagedProvider);

    return Padding(
      padding: AppSpacing.desktopPage,
      child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.cardRadius,
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetricChip(
                        icon: LucideIcons.history,
                        label: '${state.totalCount} logova',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: _buildActivityContent(state),
                ),
              ],
            ),
          )
          .animate(delay: 160.ms)
          .fadeIn(duration: Motion.smooth, curve: Motion.curve)
          .slideY(
            begin: 0.03,
            end: 0,
            duration: Motion.smooth,
            curve: Motion.curve,
          ),
    );
  }

  Widget _buildActivityContent(AdminActivityPagedState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const ShimmerTable(columnFlex: [1, 2, 4, 2, 2, 2]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ActivityFilters(
          searchController: _searchController,
          selectedOrderBy: _orderBy,
          onSearchChanged: (value) {
            ref
                .read(adminActivityPagedProvider.notifier)
                .setSearch(value.trim());
          },
          onSortChanged: (value) {
            setState(() => _orderBy = value);
            ref.read(adminActivityPagedProvider.notifier).setOrderBy(value);
          },
          onRefresh: () =>
              ref.read(adminActivityPagedProvider.notifier).load(),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: state.error != null && state.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Greska pri ucitavanju',
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.error!,
                        style: AppTextStyles.bodySecondary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      SmallButton(
                        text: 'Pokusaj ponovo',
                        color: AppColors.primary,
                        onTap: () => ref
                            .read(adminActivityPagedProvider.notifier)
                            .load(),
                      ),
                    ],
                  ),
                )
              : GenericDataTable<AdminActivityResponse>(
                  items: state.items,
                  emptyMessage: 'Nema aktivnosti.',
                  columns: [
                    ColumnDef<AdminActivityResponse>(
                      label: 'Tip',
                      flex: 2,
                      cellBuilder: (a) {
                        final isAdd =
                            a.actionType.toLowerCase() == 'add';
                        final color =
                            isAdd ? AppColors.success : AppColors.warning;
                        final icon =
                            isAdd ? LucideIcons.plus : LucideIcons.trash2;
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusSm),
                                ),
                                child: Icon(icon, size: 14, color: color),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isAdd ? 'Dodano' : 'Obrisano',
                                style: AppTextStyles.caption
                                    .copyWith(color: color),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    ColumnDef.text(
                      label: 'Opis',
                      flex: 4,
                      value: (a) => a.description,
                      bold: true,
                    ),
                    ColumnDef.text(
                      label: 'Admin',
                      flex: 2,
                      value: (a) => a.adminUsername,
                    ),
                    ColumnDef.text(
                      label: 'Vrijeme',
                      flex: 2,
                      value: (a) =>
                          _dateFormat.format(DateTimeUtils.toLocal(a.createdAt)),
                    ),
                    ColumnDef<AdminActivityResponse>(
                      label: 'Undo',
                      flex: 2,
                      cellBuilder: (a) {
                        final isUndoing =
                            state.undoInProgressIds.contains(a.id);
                        final canUndo = a.canUndo && !a.isUndone;

                        if (a.isUndone) {
                          return _UndoBadge(
                            text: 'Ponisteno',
                            color: AppColors.success,
                          );
                        }
                        if (canUndo) {
                          final remaining = DateTimeUtils.toLocal(
                            a.undoAvailableUntil,
                          ).difference(DateTime.now());
                          return Row(
                            children: [
                              SizedBox(
                                height: 28,
                                child: OutlinedButton(
                                  onPressed: isUndoing
                                      ? null
                                      : () => _undoActivity(a.id),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.35),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusSm),
                                    ),
                                  ),
                                  child: isUndoing
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child:
                                              CircularProgressIndicator(
                                                  strokeWidth: 2),
                                        )
                                      : Text(
                                          'Undo (${remaining.inMinutes.clamp(0, 59)}m)',
                                          style:
                                              AppTextStyles.caption.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          );
                        }
                        return _UndoBadge(
                          text: 'Isteklo',
                          color: AppColors.textMuted,
                        );
                      },
                    ),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        PaginationControls(
          currentPage: state.currentPage,
          totalPages: state.totalPages,
          totalCount: state.totalCount,
          onPageChanged: (page) =>
              ref.read(adminActivityPagedProvider.notifier).goToPage(page),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _UndoBadge extends StatelessWidget {
  const _UndoBadge({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ActivityFilters extends StatelessWidget {
  const _ActivityFilters({
    required this.searchController,
    required this.selectedOrderBy,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onRefresh,
  });

  final TextEditingController searchController;
  final String? selectedOrderBy;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onSortChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sort = _ActivitySortDropdown(
          value: selectedOrderBy,
          onChanged: onSortChanged,
        );

        if (constraints.maxWidth < 840) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchInput(
                controller: searchController,
                onSubmitted: onSearchChanged,
                hintText: 'Pretraga po opisu ili adminu...',
              ),
              const SizedBox(height: AppSpacing.md),
              sort,
              const SizedBox(height: AppSpacing.md),
              SmallButton(
                text: 'Osvjezi',
                color: AppColors.secondary,
                onTap: onRefresh,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: SearchInput(
                controller: searchController,
                onSubmitted: onSearchChanged,
                hintText: 'Pretraga po opisu ili adminu...',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            sort,
            const SizedBox(width: AppSpacing.md),
            SmallButton(
              text: 'Osvjezi',
              color: AppColors.secondary,
              onTap: onRefresh,
            ),
          ],
        );
      },
    );
  }
}

class _ActivitySortDropdown extends StatelessWidget {
  const _ActivitySortDropdown({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.smallRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          hint: Text('Sort', style: AppTextStyles.bodySecondary),
          dropdownColor: AppColors.surface,
          style: AppTextStyles.bodySecondary,
          icon: const Icon(
            LucideIcons.arrowUpDown,
            color: AppColors.textMuted,
            size: 15,
          ),
          items: const [
            DropdownMenuItem(value: null, child: Text('Zadano (najnovije)')),
            DropdownMenuItem(
              value: 'createdat',
              child: Text('Datum (najstarije)'),
            ),
            DropdownMenuItem(value: 'admin', child: Text('Admin (A-Z)')),
            DropdownMenuItem(
              value: 'admindesc',
              child: Text('Admin (Z-A)'),
            ),
            DropdownMenuItem(
              value: 'actiontype',
              child: Text('Tip akcije (A-Z)'),
            ),
            DropdownMenuItem(
              value: 'actiontypedesc',
              child: Text('Tip akcije (Z-A)'),
            ),
            DropdownMenuItem(
              value: 'entitytype',
              child: Text('Tip entiteta (A-Z)'),
            ),
            DropdownMenuItem(
              value: 'entitytypedesc',
              child: Text('Tip entiteta (Z-A)'),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
