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
import '../providers/leaderboard_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/leaderboard/leaderboard_table.dart';
import '../widgets/shared/chrome_tab_bar.dart';
import '../widgets/shared/crud_list_scaffold.dart';
import '../widgets/shared/error_animation.dart';
import '../widgets/shared/shimmer_loading.dart';
import '../widgets/shared/success_animation.dart';
import '../widgets/users/user_add_dialog.dart';
import '../widgets/users/users_table.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    (icon: LucideIcons.users, label: 'Korisnici'),
    (icon: LucideIcons.trophy, label: 'Rang Lista'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userListProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addUser() async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => const UserAddDialog(),
    );
    if (result == true && mounted) {
      showSuccessAnimation(context);
    } else if (result is String && mounted) {
      showErrorAnimation(context, message: result);
    }
  }

  void _openProfile(UserResponse user) {
    context.go('/users/${user.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.desktopPage,
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
                  _buildUsersTab(),
                  _buildLeaderboardTab(),
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

  Widget _buildUsersTab() {
    final state = ref.watch(userListProvider);
    final notifier = ref.read(userListProvider.notifier);

    return CrudListScaffold<UserResponse, UserQueryFilter>(
      state: state,
      onRefresh: notifier.refresh,
      onSearch: notifier.setSearch,
      onSort: notifier.setOrderBy,
      onPageChanged: notifier.goToPage,
      onAdd: _addUser,
      searchHint: 'Pretrazi korisnike...',
      addButtonText: '+ Dodaj korisnika',
      sortOptions: const [
        SortOption(value: null, label: 'Zadano'),
        SortOption(value: 'firstname', label: 'Ime (A-Z)'),
        SortOption(value: 'lastname', label: 'Prezime (A-Z)'),
        SortOption(value: 'datedesc', label: 'Najnovije prvo'),
        SortOption(value: 'date', label: 'Najstarije prvo'),
      ],
      tableBuilder: (items) => UsersTable(
        users: items,
        onViewProfile: _openProfile,
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: leaderboardAsync.when(
        loading: () =>
            const ShimmerTable(columnFlex: [1, 4, 2, 2], rowCount: 10),
        error: (error, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Greska pri ucitavanju', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppSpacing.sm),
            Text(error.toString(),
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            GradientButton.text(
              text: 'Pokusaj ponovo',
              onPressed: () => ref.invalidate(leaderboardProvider),
            ),
          ]),
        ),
        data: (entries) => LeaderboardTable(entries: entries),
      ),
    );
  }
}
