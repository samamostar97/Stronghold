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
import '../widgets/shared/success_animation.dart';
import '../widgets/shared/small_button.dart';

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
    _searchController.dispose();
    _tabController.dispose();
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
    final activeCount = paymentsState.items.where((x) => x.isActive).length;

    return Padding(
      padding: AppSpacing.desktopPage,
      child:
          Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AuditHeader(
                    pageAmount: pageAmount,
                    activeCount: activeCount,
                    activitiesCount: activityState.items.length,
                    onOpenReports: () => context.go('/reports'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          top: chromeTabBarHeight - 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              border: Border.all(color: AppColors.border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: TabBarView(
                              controller: _tabController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _MembershipPaymentsAuditTab(
                                  dateFormat: _dateFormat,
                                  searchController: _searchController,
                                  selectedOrderBy: _selectedOrderBy,
                                  onSearchChanged: (value) {
                                    ref
                                        .read(
                                          membershipPaymentsProvider.notifier,
                                        )
                                        .setSearch(value.trim());
                                  },
                                  onSortChanged: (value) {
                                    setState(() => _selectedOrderBy = value);
                                    ref
                                        .read(
                                          membershipPaymentsProvider.notifier,
                                        )
                                        .setOrderBy(value);
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: DashboardAdminActivityFeed(
                                    items: activityState.items,
                                    isLoading: activityState.isLoading,
                                    undoInProgressIds:
                                        activityState.undoInProgressIds,
                                    error: activityState.error,
                                    onRetry: () => ref
                                        .read(adminActivityProvider.notifier)
                                        .load(count: 120),
                                    onUndo: _undoActivity,
                                    expand: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: chromeTabBarHeight,
                          child: ChromeTabBar(
                            controller: _tabController,
                            tabs: _tabs,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              .animate(delay: 200.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(
                begin: 0.04,
                end: 0,
                duration: Motion.smooth,
                curve: Motion.curve,
              ),
    );
  }
}

class _AuditHeader extends StatelessWidget {
  const _AuditHeader({
    required this.pageAmount,
    required this.activeCount,
    required this.activitiesCount,
    required this.onOpenReports,
  });

  final num pageAmount;
  final int activeCount;
  final int activitiesCount;
  final VoidCallback onOpenReports;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: AppSpacing.panelRadius,
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(
                  LucideIcons.shieldCheck,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audit centar',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Uplate clanarina i admin aktivnosti na jednom mjestu',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _AuditChip(
                icon: LucideIcons.banknote,
                label: 'Uplate (stranica)',
                value: '${pageAmount.toStringAsFixed(2)} KM',
              ),
              _AuditChip(
                icon: LucideIcons.badgeCheck,
                label: 'Aktivne clanarine',
                value: '$activeCount',
              ),
              _AuditChip(
                icon: LucideIcons.history,
                label: 'Aktivnosti',
                value: '$activitiesCount',
              ),
              SmallButton(
                text: 'Otvori izvjestaje',
                color: AppColors.primary,
                onTap: onOpenReports,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuditChip extends StatelessWidget {
  const _AuditChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$label: $value',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipPaymentsAuditTab extends ConsumerWidget {
  const _MembershipPaymentsAuditTab({
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
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: ShimmerTable(columnFlex: [3, 3, 2, 2, 3, 2, 2]),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PaymentsFilters(
            searchController: searchController,
            selectedOrderBy: selectedOrderBy,
            onSearchChanged: onSearchChanged,
            onSortChanged: onSortChanged,
            onRefresh: () =>
                ref.read(membershipPaymentsProvider.notifier).load(),
          ),
          const SizedBox(height: AppSpacing.lg),
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
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          state.error!,
                          style: AppTextStyles.bodySecondary,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
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
                            color: AppColors.secondary,
                            onTap: () => context.go('/users/${p.userId}'),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PaginationControls(
            currentPage: state.currentPage,
            totalPages: state.totalPages,
            totalCount: state.totalCount,
            onPageChanged: (page) =>
                ref.read(membershipPaymentsProvider.notifier).goToPage(page),
          ),
        ],
      ),
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
                color: AppColors.primary,
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
            const SizedBox(width: AppSpacing.lg),
            sort,
            const SizedBox(width: AppSpacing.lg),
            SmallButton(
              text: 'Osvjezi',
              color: AppColors.primary,
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
          hint: Text('Sortiraj', style: AppTextStyles.bodySecondary),
          dropdownColor: AppColors.surface,
          style: AppTextStyles.bodyMedium,
          icon: Icon(
            LucideIcons.arrowUpDown,
            color: AppColors.textMuted,
            size: 16,
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
