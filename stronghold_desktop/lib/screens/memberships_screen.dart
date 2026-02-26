import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/user_provider.dart';
import '../providers/membership_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/shared/confirm_dialog.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/memberships/membership_payment_dialog.dart';
import '../widgets/memberships/memberships_table.dart';
import '../widgets/shared/pagination_controls.dart';
import '../widgets/shared/search_input.dart';
import '../widgets/shared/shimmer_loading.dart';
import '../widgets/shared/success_animation.dart';
import 'payment_history_screen.dart';

class MembershipsScreen extends ConsumerStatefulWidget {
  const MembershipsScreen({super.key});

  @override
  ConsumerState<MembershipsScreen> createState() => _MembershipsScreenState();
}

class _MembershipsScreenState extends ConsumerState<MembershipsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userListProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _viewPayments(UserResponse user) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PaymentHistoryScreen(user: user)));
  }

  Future<void> _addPayment(UserResponse user) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => MembershipPaymentDialog(user: user),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
      ref.invalidate(userHasActiveMembershipProvider(user.id));
      ref.invalidate(userPaymentsProvider(UserPaymentsParams(
        userId: user.id,
        filter: MembershipQueryFilter(pageSize: 10),
      )));
    }
  }

  Future<void> _revokeMembership(UserResponse user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Ukini clanarinu?',
        message:
            'Da li ste sigurni da zelite ukinuti clanarinu za korisnika ${user.firstName} ${user.lastName}?',
        confirmText: 'Da, ukini',
        cancelText: 'Ne',
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(membershipOperationsProvider.notifier)
          .revokeMembership(user.id);
      if (mounted) {
        showSuccessAnimation(context);
        ref.invalidate(userHasActiveMembershipProvider(user.id));
        ref.invalidate(userPaymentsProvider(UserPaymentsParams(
          userId: user.id,
          filter: MembershipQueryFilter(pageSize: 10),
        )));
      }
    } catch (e) {
      if (mounted) {
        showErrorAnimation(context,
            message:
                ErrorHandler.getContextualMessage(e, 'revoke-membership'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Content
        Expanded(
          child: _MembershipContent(
            state: state,
            searchController: _searchController,
            onSearch: (q) =>
                ref.read(userListProvider.notifier).setSearch(q),
            onSort: (v) =>
                ref.read(userListProvider.notifier).setOrderBy(v),
            onPage: (p) =>
                ref.read(userListProvider.notifier).goToPage(p),
            onLoad: () => ref.read(userListProvider.notifier).load(),
            onViewPayments: _viewPayments,
            onAddPayment: _addPayment,
            onRevoke: _revokeMembership,
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(
                begin: 0.04,
                end: 0,
                duration: Motion.smooth,
                curve: Motion.curve,
              ),
        ),
      ],
    );
  }
}

class _MembershipContent extends StatelessWidget {
  const _MembershipContent({
    required this.state,
    required this.searchController,
    required this.onSearch,
    required this.onSort,
    required this.onPage,
    required this.onLoad,
    required this.onViewPayments,
    required this.onAddPayment,
    required this.onRevoke,
  });

  final dynamic state;
  final TextEditingController searchController;
  final ValueChanged<String?> onSearch;
  final ValueChanged<String?> onSort;
  final ValueChanged<int> onPage;
  final VoidCallback onLoad;
  final ValueChanged<UserResponse> onViewPayments;
  final ValueChanged<UserResponse> onAddPayment;
  final ValueChanged<UserResponse> onRevoke;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final pad = w > 1200 ? 40.0 : w > 800 ? 24.0 : 16.0;

      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: pad, vertical: AppSpacing.xl),
        child: Container(
          padding: EdgeInsets.all(w > 600 ? 30 : AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppSpacing.cardRadius,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SearchInput(
                      controller: searchController,
                      onSubmitted: onSearch,
                      hintText:
                          'Pretrazi po imenu, prezimenu ili korisnickom imenu...',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _SortDropdown(
                    value: state.filter.orderBy,
                    onChanged: onSort,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBody() {
    if (state.isLoading) {
      return const ShimmerTable(columnFlex: [2, 2, 2, 3, 4]);
    }
    if (state.error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Greska pri ucitavanju', style: AppTextStyles.cardTitle),
          const SizedBox(height: AppSpacing.sm),
          Text(state.error!,
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          GradientButton.text(text: 'Pokusaj ponovo', onPressed: onLoad),
        ]),
      );
    }
    final users = state.data?.items ?? <UserResponse>[];
    final totalPages =
        state.data?.totalPages(state.filter.pageSize) ?? 1;
    final totalCount = state.data?.totalCount ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: MembershipsTable(
            users: users,
            onViewPayments: onViewPayments,
            onAddPayment: onAddPayment,
            onRevokeMembership: onRevoke,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        PaginationControls(
          currentPage: state.filter.pageNumber,
          totalPages: totalPages,
          totalCount: totalCount,
          onPageChanged: onPage,
        ),
      ],
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;

  static const _options = [
    (value: null, label: 'Zadano'),
    (value: 'firstname', label: 'Ime (A-Z)'),
    (value: 'membershipstatus', label: 'Status (aktivne prvo)'),
    (value: 'membershipstatusdesc', label: 'Status (istekle prvo)'),
    (value: 'expirydatedesc', label: 'Istek (najskorije)'),
    (value: 'expirydate', label: 'Istek (najkasnije)'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.smallRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _options.any((o) => o.value == value) ? value : null,
          icon: const Icon(Icons.sort, color: AppColors.textMuted, size: 18),
          dropdownColor: AppColors.surface,
          style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary),
          items: _options
              .map((o) => DropdownMenuItem<String?>(
                    value: o.value,
                    child: Text(o.label, style: o.value == null
                        ? AppTextStyles.bodyBold
                        : AppTextStyles.bodySecondary),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
