import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/admin_activity_provider.dart';
import '../providers/membership_payments_provider.dart';
import '../widgets/dashboard/dashboard_admin_activity_feed.dart';
import '../widgets/shared/chrome_tab_bar.dart';
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

class _AuditScreenState extends ConsumerState<AuditScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');
  String? _selectedOrderBy;

  static const _tabs = [
    (icon: LucideIcons.receipt, label: 'Uplate clanarina'),
    (icon: LucideIcons.history, label: 'Admin aktivnosti'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(membershipPaymentsProvider.notifier).load();
      await ref.read(adminActivityProvider.notifier).load(count: 120);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _undoActivity(int id) async {
    try {
      await ref.read(adminActivityProvider.notifier).undo(id);
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
    final paymentsState = ref.watch(membershipPaymentsProvider);
    final activityState = ref.watch(adminActivityProvider);

    final pageAmount = paymentsState.items.fold<num>(
      0,
      (sum, payment) => sum + payment.amountPaid,
    );
    final activeCount = paymentsState.items.where((p) => p.isActive).length;

    return Padding(
      padding: AppSpacing.desktopPage,
      child:
          Container(
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
                            icon: LucideIcons.banknote,
                            label: '${pageAmount.toStringAsFixed(2)} KM',
                          ),
                          _MetricChip(
                            icon: LucideIcons.badgeCheck,
                            label: '$activeCount aktivnih',
                          ),
                          _MetricChip(
                            icon: LucideIcons.history,
                            label: '${activityState.items.length} logova',
                          ),
                          SmallButton(
                            text: 'Izvjestaji',
                            color: AppColors.primary,
                            onTap: () => context.go('/reports'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: chromeTabBarHeight,
                      child: ChromeTabBar(
                        controller: _tabController,
                        tabs: _tabs,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _MembershipPaymentsTab(
                            dateFormat: _dateFormat,
                            searchController: _searchController,
                            selectedOrderBy: _selectedOrderBy,
                            onSearchChanged: (value) {
                              ref
                                  .read(membershipPaymentsProvider.notifier)
                                  .setSearch(value.trim());
                            },
                            onSortChanged: (value) {
                              setState(() => _selectedOrderBy = value);
                              ref
                                  .read(membershipPaymentsProvider.notifier)
                                  .setOrderBy(value);
                            },
                          ),
                          DashboardAdminActivityFeed(
                            items: activityState.items,
                            isLoading: activityState.isLoading,
                            undoInProgressIds: activityState.undoInProgressIds,
                            error: activityState.error,
                            onRetry: () => ref
                                .read(adminActivityProvider.notifier)
                                .load(count: 120),
                            onUndo: _undoActivity,
                            expand: true,
                            embedded: true,
                          ),
                        ],
                      ),
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

class _MembershipPaymentsTab extends ConsumerWidget {
  const _MembershipPaymentsTab({
    required this.dateFormat,
    required this.searchController,
    required this.selectedOrderBy,
    required this.onSearchChanged,
    required this.onSortChanged,
  });

  final DateFormat dateFormat;
  final TextEditingController searchController;
  final String? selectedOrderBy;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onSortChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(membershipPaymentsProvider);

    if (state.isLoading && state.items.isEmpty) {
      return const ShimmerTable(columnFlex: [3, 3, 2, 2, 3, 2, 2]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PaymentsFilters(
          searchController: searchController,
          selectedOrderBy: selectedOrderBy,
          onSearchChanged: onSearchChanged,
          onSortChanged: onSortChanged,
          onRefresh: () => ref.read(membershipPaymentsProvider.notifier).load(),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: state.error != null
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
                            .read(membershipPaymentsProvider.notifier)
                            .load(),
                      ),
                    ],
                  ),
                )
              : GenericDataTable<AdminMembershipPaymentResponse>(
                  items: state.items,
                  emptyMessage: 'Nema uplata za prikaz.',
                  columns: [
                    ColumnDef.text(
                      label: 'Korisnik',
                      flex: 3,
                      value: (p) => p.userName,
                      bold: true,
                    ),
                    ColumnDef.text(
                      label: 'Email',
                      flex: 3,
                      value: (p) => p.userEmail,
                    ),
                    ColumnDef.text(
                      label: 'Paket',
                      flex: 2,
                      value: (p) => p.packageName,
                    ),
                    ColumnDef.text(
                      label: 'Iznos',
                      flex: 2,
                      value: (p) => '${p.amountPaid.toStringAsFixed(2)} KM',
                    ),
                    ColumnDef.text(
                      label: 'Uplata',
                      flex: 2,
                      value: (p) => dateFormat.format(p.paymentDate),
                    ),
                    ColumnDef.text(
                      label: 'Period',
                      flex: 3,
                      value: (p) =>
                          '${DateFormat('dd.MM.yyyy').format(p.startDate)} - ${DateFormat('dd.MM.yyyy').format(p.endDate)}',
                    ),
                    ColumnDef<AdminMembershipPaymentResponse>(
                      label: 'Status',
                      flex: 2,
                      cellBuilder: (p) => Align(
                        alignment: Alignment.centerLeft,
                        child: StatusPill(
                          label: p.isActive ? 'Aktivna' : 'Istekla',
                          color: p.isActive
                              ? AppColors.success
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    ColumnDef.actions(
                      flex: 2,
                      builder: (p) => [
                        SmallButton(
                          text: 'Profil',
                          color: AppColors.primary,
                          onTap: () => context.go('/users/${p.userId}'),
                        ),
                      ],
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
              ref.read(membershipPaymentsProvider.notifier).goToPage(page),
        ),
      ],
    );
  }
}

class _PaymentsFilters extends StatelessWidget {
  const _PaymentsFilters({
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
        final sort = _SortDropdown(
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
                hintText: 'Pretraga po korisniku, email-u ili paketu...',
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
                hintText: 'Pretraga po korisniku, email-u ili paketu...',
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

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.value, required this.onChanged});

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
            DropdownMenuItem(value: null, child: Text('Zadano')),
            DropdownMenuItem(
              value: 'datedesc',
              child: Text('Datum (najnovije)'),
            ),
            DropdownMenuItem(value: 'date', child: Text('Datum (najstarije)')),
            DropdownMenuItem(value: 'amountdesc', child: Text('Iznos (veci)')),
            DropdownMenuItem(value: 'amount', child: Text('Iznos (manji)')),
            DropdownMenuItem(value: 'user', child: Text('Korisnik (A-Z)')),
            DropdownMenuItem(value: 'userdesc', child: Text('Korisnik (Z-A)')),
            DropdownMenuItem(value: 'packagename', child: Text('Paket (A-Z)')),
            DropdownMenuItem(
              value: 'packagenamedesc',
              child: Text('Paket (Z-A)'),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
