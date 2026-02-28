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
import '../widgets/shared/chrome_tab_bar.dart';
import '../widgets/users/user_info_tab.dart';
import '../widgets/users/user_management_tab.dart';
import '../widgets/users/user_orders_tab.dart';
import '../widgets/users/user_payments_tab.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key, required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(userId));

    return userAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Greska pri ucitavanju korisnika',
              style: AppTextStyles.cardTitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(e.toString(), style: AppTextStyles.bodySecondary),
            const SizedBox(height: AppSpacing.lg),
            TextButton.icon(
              onPressed: () => context.go('/users'),
              icon: const Icon(
                LucideIcons.arrowLeft,
                size: 16,
                color: AppColors.primary,
              ),
              label: Text(
                'Nazad na korisnike',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
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
    return Padding(
      padding: AppSpacing.desktopPage,
      child:
          Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileToolbar(
                    user: widget.user,
                    onBack: () => context.go('/users'),
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                                UserInfoTab(user: widget.user),
                                UserOrdersTab(userId: widget.user.id),
                                UserPaymentsTab(userId: widget.user.id),
                                UserManagementTab(user: widget.user),
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
              .animate(delay: 100.ms)
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

class _ProfileToolbar extends StatelessWidget {
  const _ProfileToolbar({required this.user, required this.onBack});

  final UserResponse user;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(user.firstName, user.lastName);
    final avatar = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: user.profileImageUrl != null
          ? Image.network(
              ApiConfig.imageUrl(user.profileImageUrl!),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _InitialsAvatar(initials: initials),
            )
          : _InitialsAvatar(initials: initials),
    );

    final identity = Row(
      children: [
        avatar,
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: AppTextStyles.sectionTitle,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '@${user.username}',
                style: AppTextStyles.caption,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    final chips = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetaChip(icon: LucideIcons.mail, value: user.email),
        if (user.phoneNumber.isNotEmpty)
          _MetaChip(icon: LucideIcons.phone, value: user.phoneNumber),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.panelRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 980;
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _BackChip(onTap: onBack),
                    const SizedBox(width: 8),
                    Expanded(child: identity),
                  ],
                ),
                const SizedBox(height: 8),
                chips,
              ],
            );
          }

          return Row(
            children: [
              _BackChip(onTap: onBack),
              const SizedBox(width: 10),
              Expanded(child: identity),
              const SizedBox(width: 12),
              Flexible(child: chips),
            ],
          );
        },
      ),
    );
  }

  static String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    return '$f$l'.toUpperCase();
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceAlt,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.caption,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackChip extends StatefulWidget {
  const _BackChip({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_BackChip> createState() => _BackChipState();
}

class _BackChipState extends State<_BackChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _hover ? AppColors.surfaceHover : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.arrowLeft,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text('Nazad', style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
      ),
    );
  }
}
