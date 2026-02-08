import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/user_provider.dart';
import '../providers/membership_provider.dart';
import '../utils/error_handler.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/error_animation.dart';
import '../widgets/gradient_button.dart';
import '../widgets/membership_payment_dialog.dart';
import '../widgets/memberships_table.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/search_input.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/success_animation.dart';
import 'payment_history_screen.dart';

class MembershipsScreen extends ConsumerStatefulWidget {
  const MembershipsScreen({super.key, this.embedded = false});
  final bool embedded;

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
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final pad = w > 1200 ? 40.0 : w > 800 ? 24.0 : 16.0;
      return Padding(
        padding:
            EdgeInsets.symmetric(horizontal: pad, vertical: AppSpacing.xl),
        child: Container(
          padding: EdgeInsets.all(w > 600 ? 30 : AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceSolid,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Upravljanje clanarinama',
                  style: AppTextStyles.headingMd),
              const SizedBox(height: AppSpacing.xxl),
              SearchInput(
                controller: _searchController,
                onSubmitted: (q) =>
                    ref.read(userListProvider.notifier).setSearch(q),
                hintText:
                    'Pretrazi po imenu, prezimenu ili korisnickom imenu...',
              ),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(child: _buildContent(state)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildContent(dynamic userState) {
    if (userState.isLoading) {
      return const ShimmerTable(columnFlex: [2, 2, 2, 3, 4]);
    }
    if (userState.error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Greska pri ucitavanju', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.sm),
          Text(userState.error!,
              style: AppTextStyles.bodyMd, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            text: 'Pokusaj ponovo',
            onTap: () => ref.read(userListProvider.notifier).load(),
          ),
        ]),
      );
    }
    final users = userState.data?.items ?? <UserResponse>[];
    final totalPages =
        userState.data?.totalPages(userState.filter.pageSize) ?? 1;
    final totalCount = userState.data?.totalCount ?? 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(
        child: MembershipsTable(
          users: users,
          onViewPayments: _viewPayments,
          onAddPayment: _addPayment,
          onRevokeMembership: _revokeMembership,
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      PaginationControls(
        currentPage: userState.filter.pageNumber,
        totalPages: totalPages,
        totalCount: totalCount,
        onPageChanged: (p) =>
            ref.read(userListProvider.notifier).goToPage(p),
      ),
    ]);
  }
}
