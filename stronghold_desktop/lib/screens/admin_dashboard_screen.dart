import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../widgets/admin_content_area.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/command_palette.dart';
import 'login_screen.dart';

/// All available admin screens.
enum AdminScreen {
  dashboardHome,
  currentVisitors,
  memberships,
  membershipPackages,
  users,
  trainers,
  nutritionists,
  supplements,
  categories,
  suppliers,
  orders,
  faq,
  reviews,
  seminars,
  businessReport,
  leaderboard,
}

// ---------------------------------------------------------------------------
// NAVIGATION DATA
// ---------------------------------------------------------------------------

const _navGroups = [
  NavGroup(items: [
    NavItem(id: 'dashboardHome', label: 'Kontrolna ploca',
        icon: LucideIcons.layoutDashboard),
  ]),
  NavGroup(label: 'UPRAVLJANJE', items: [
    NavItem(id: 'currentVisitors', label: 'Trenutno u teretani',
        icon: LucideIcons.activity),
    NavItem(id: 'memberships', label: 'Clanarine',
        icon: LucideIcons.creditCard),
    NavItem(id: 'membershipPackages', label: 'Paketi clanarina',
        icon: LucideIcons.package2),
    NavItem(id: 'users', label: 'Korisnici', icon: LucideIcons.users),
  ]),
  NavGroup(label: 'OSOBLJE', items: [
    NavItem(id: 'trainers', label: 'Treneri', icon: LucideIcons.dumbbell),
    NavItem(id: 'nutritionists', label: 'Nutricionisti',
        icon: LucideIcons.apple),
  ]),
  NavGroup(label: 'PRODAVNICA', items: [
    NavItem(id: 'supplements', label: 'Suplementi', icon: LucideIcons.pill),
    NavItem(id: 'categories', label: 'Kategorije', icon: LucideIcons.tag),
    NavItem(id: 'suppliers', label: 'Dobavljaci', icon: LucideIcons.truck),
    NavItem(id: 'orders', label: 'Kupovine',
        icon: LucideIcons.shoppingBag),
  ]),
  NavGroup(label: 'SADRZAJ', items: [
    NavItem(id: 'faq', label: 'FAQ', icon: LucideIcons.helpCircle),
    NavItem(id: 'reviews', label: 'Recenzije', icon: LucideIcons.star),
    NavItem(id: 'seminars', label: 'Seminari',
        icon: LucideIcons.graduationCap),
  ]),
  NavGroup(label: 'ANALITIKA', items: [
    NavItem(id: 'businessReport', label: 'Biznis izvjestaji',
        icon: LucideIcons.trendingUp),
    NavItem(id: 'leaderboard', label: 'Rang lista',
        icon: LucideIcons.trophy),
  ]),
];

final _screenById = {
  for (final s in AdminScreen.values) s.name: s,
};

// ---------------------------------------------------------------------------
// MAIN DASHBOARD SHELL
// ---------------------------------------------------------------------------

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  AdminScreen _selected = AdminScreen.dashboardHome;
  bool _collapsed = false;
  bool? _userCollapse;

  void _onSelect(String id) {
    final screen = _screenById[id];
    if (screen != null) setState(() => _selected = screen);
  }

  void _toggleCollapse() {
    setState(() {
      _collapsed = !_collapsed;
      _userCollapse = _collapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
            showCommandPalette(context, onNavigate: (s) {
              setState(() => _selected = s);
            }),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final collapsed = _userCollapse ?? constraints.maxWidth < 1200;

              return SafeArea(
                child: Row(
                  children: [
                    AppSidebar(
                      groups: _navGroups,
                      activeId: _selected.name,
                      onSelect: _onSelect,
                      collapsed: collapsed,
                      onToggleCollapse: _toggleCollapse,
                      bottom: _SidebarProfile(collapsed: collapsed),
                    ),
                    Expanded(
                      child: AdminContentArea(
                        selectedScreen: _selected,
                        onNavigate: (s) => setState(() => _selected = s),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SIDEBAR PROFILE
// ---------------------------------------------------------------------------

class _SidebarProfile extends StatelessWidget {
  const _SidebarProfile({required this.collapsed});

  final bool collapsed;

  Future<void> _logout(BuildContext context) async {
    await TokenStorage.clear();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, -100),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      color: AppColors.surfaceSolid,
      onSelected: (v) {
        if (v == 'logout') _logout(context);
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(children: [
            const Icon(LucideIcons.user,
                color: AppColors.textSecondary, size: 18),
            const SizedBox(width: AppSpacing.md),
            Text('Profil', style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.textPrimary)),
          ]),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(children: [
            const Icon(LucideIcons.logOut,
                color: AppColors.error, size: 18),
            const SizedBox(width: AppSpacing.md),
            Text('Odjavi se', style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.error)),
          ]),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (collapsed || constraints.maxWidth < 80) {
              return const Center(
                  child: AvatarWidget(initials: 'AD', size: 36));
            }
            return Row(children: [
              const AvatarWidget(initials: 'AD', size: 36),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text('Admin', style: AppTextStyles.bodyBold,
                    overflow: TextOverflow.ellipsis),
              ),
              Icon(LucideIcons.chevronUp,
                  color: AppColors.textMuted, size: 16),
            ]);
          },
        ),
      ),
    );
  }
}
