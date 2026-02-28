import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../constants/motion.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/users/user_info_tab.dart';
import '../widgets/users/user_orders_tab.dart';
import '../widgets/users/user_payments_tab.dart';
import '../widgets/users/user_management_tab.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key, required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(userId));

    return userAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.electric),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Greska pri ucitavanju korisnika',
                style: AppTextStyles.cardTitle),
            const SizedBox(height: AppSpacing.sm),
            Text(e.toString(), style: AppTextStyles.bodySecondary),
            const SizedBox(height: AppSpacing.lg),
            TextButton.icon(
              onPressed: () => context.go('/users'),
              icon: Icon(LucideIcons.arrowLeft,
                  size: 16, color: AppColors.electric),
              label: Text('Nazad na korisnike',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.electric)),
            ),
          ],
        ),
      ),
      data: (user) => _UserProfileContent(user: user),
    );
  }
}

class _UserProfileContent extends StatefulWidget {
  const _UserProfileContent({required this.user});
  final UserResponse user;

  @override
  State<_UserProfileContent> createState() => _UserProfileContentState();
}

class _UserProfileContentState extends State<_UserProfileContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    (icon: LucideIcons.user, label: 'Informacije'),
    (icon: LucideIcons.shoppingBag, label: 'Narudzbe'),
    (icon: LucideIcons.receipt, label: 'Uplate'),
    (icon: LucideIcons.settings, label: 'Upravljanje'),
  ];

  static const _tabBarHeight = 46.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final pad = w > 1200
            ? 40.0
            : w > 800
                ? 24.0
                : 16.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: AppSpacing.xl),
          child: Stack(
            children: [
              // Content panel
              Positioned.fill(
                top: _tabBarHeight - 1,
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
                    children: [
                      UserInfoTab(user: widget.user),
                      UserOrdersTab(userId: widget.user.id),
                      UserPaymentsTab(userId: widget.user.id),
                      UserManagementTab(user: widget.user),
                    ],
                  ),
                ),
              ),
              // Tab bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _tabBarHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back button
                    _BackButton(onTap: () => context.go('/users')),
                    const SizedBox(width: 2),
                    for (int i = 0; i < _tabs.length; i++) ...[
                      if (i > 0) const SizedBox(width: 2),
                      _ProfileChromeTab(
                        icon: _tabs[i].icon,
                        label: _tabs[i].label,
                        isActive: _tabController.index == i,
                        onTap: () => _tabController.animateTo(i),
                      ),
                    ],
                    const Spacer(),
                  ],
                ),
              ),
            ],
          )
              .animate(delay: 100.ms)
              .fadeIn(duration: Motion.smooth, curve: Motion.curve)
              .slideY(
                begin: 0.03,
                end: 0,
                duration: Motion.smooth,
                curve: Motion.curve,
              ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════
//  BACK BUTTON (styled like an inactive chrome tab)
// ═══════════════════════════════════════════════════

class _BackButton extends StatefulWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Motion.curve,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.surfaceAlt : AppColors.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border.all(
              color: _hovered
                  ? AppColors.border
                  : AppColors.border.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.arrowLeft,
                  size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Nazad',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  CHROME-STYLE TAB (same visual as StaffScreen)
// ═══════════════════════════════════════════════════

class _ProfileChromeTab extends StatefulWidget {
  const _ProfileChromeTab({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_ProfileChromeTab> createState() => _ProfileChromeTabState();
}

class _ProfileChromeTabState extends State<_ProfileChromeTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: active ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Motion.curve,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: active
                ? AppColors.surface
                : _hovered
                    ? AppColors.surfaceAlt
                    : AppColors.background,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: active
                ? null
                : Border.all(
                    color: _hovered
                        ? AppColors.border
                        : AppColors.border.withValues(alpha: 0.5),
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: active ? AppColors.electric : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: active
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
