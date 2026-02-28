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
import '../widgets/shared/screen_intro_banner.dart';
import '../widgets/shared/shimmer_loading.dart';
import '../widgets/shared/success_animation.dart';
import '../widgets/users/user_add_dialog.dart';
import '../widgets/shared/data_table_widgets.dart';
import '../widgets/shared/small_button.dart';

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
      child:
          Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScreenIntroBanner(
                    icon: LucideIcons.users,
                    title: 'Korisnicki centar',
                    subtitle: 'Upravljanje clanovima i pregled rang liste',
                    trailing: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        SmallButton(
                          text: 'Dodaj korisnika',
                          color: AppColors.primary,
                          onTap: _addUser,
                        ),
                        SmallButton(
                          text: 'Rang lista',
                          color: AppColors.secondary,
                          onTap: () => _tabController.animateTo(1),
                        ),
                      ],
                    ),
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
      tableBuilder: (items) => GenericDataTable<UserResponse>(
        items: items,
        columns: [
          ColumnDef<UserResponse>(
            label: '',
            flex: 1,
            cellBuilder: (u) {
              final initials = _initials(u.firstName, u.lastName);
              return Align(
                alignment: Alignment.centerLeft,
                child: u.profileImageUrl != null
                    ? Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                          child: Image.network(
                            ApiConfig.imageUrl(u.profileImageUrl!),
                            fit: BoxFit.cover,
                            width: 32,
                            height: 32,
                            errorBuilder: (_, _, _) =>
                                AvatarWidget(initials: initials, size: 32),
                          ),
                        ),
                      )
                    : AvatarWidget(initials: initials, size: 32),
              );
            },
          ),
          ColumnDef.text(
            label: 'Ime i prezime',
            flex: 3,
            value: (u) => '${u.firstName} ${u.lastName}',
            bold: true,
          ),
          ColumnDef.text(
            label: 'Korisnicko ime',
            flex: 2,
            value: (u) => u.username,
          ),
          ColumnDef.text(label: 'Email', flex: 3, value: (u) => u.email),
          ColumnDef.text(
            label: 'Telefon',
            flex: 2,
            value: (u) => u.phoneNumber,
          ),
          ColumnDef.actions(
            flex: 2,
            builder: (u) => [
              SmallButton(
                text: 'Informacije',
                color: AppColors.primary,
                onTap: () => _openProfile(u),
              ),
            ],
          ),
        ],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Greska pri ucitavanju', style: AppTextStyles.cardTitle),
              const SizedBox(height: AppSpacing.sm),
              Text(
                error.toString(),
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              GradientButton.text(
                text: 'Pokusaj ponovo',
                onPressed: () => ref.invalidate(leaderboardProvider),
              ),
            ],
          ),
        ),
        data: (entries) => LeaderboardTable(entries: entries),
      ),
    );
  }

  static String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    return '$f$l'.toUpperCase();
  }
}
