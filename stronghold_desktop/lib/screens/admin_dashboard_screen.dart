import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stronghold_desktop/screens/business_report_screen.dart';
import 'package:stronghold_desktop/screens/visitors_screen.dart';
import 'package:stronghold_desktop/screens/supplements_screen.dart';
import 'package:stronghold_desktop/screens/categories_screen.dart';
import 'package:stronghold_desktop/screens/suppliers_screen.dart';
import 'package:stronghold_desktop/screens/trainers_screen.dart';
import 'package:stronghold_desktop/screens/nutritionists_screen.dart';
import 'package:stronghold_desktop/screens/users_screen.dart';
import 'package:stronghold_desktop/screens/faq_screen.dart';
import 'package:stronghold_desktop/screens/orders_screen.dart';
import 'package:stronghold_desktop/screens/reviews_screen.dart';
import 'package:stronghold_desktop/screens/seminars_screen.dart';
import 'package:stronghold_desktop/screens/membership_packages_screen.dart';
import 'package:stronghold_desktop/screens/memberships_screen.dart';
import 'package:stronghold_desktop/screens/leaderboard_screen.dart';
import 'package:stronghold_desktop/screens/dashboard_home_screen.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'package:stronghold_desktop/screens/login_screen.dart';
import '../constants/app_colors.dart';
import '../constants/app_theme.dart';
import '../widgets/command_palette.dart';

/// Enum representing all available admin screens
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

// ─────────────────────────────────────────────────────────────────────────────
// NAVIGATION DATA
// ─────────────────────────────────────────────────────────────────────────────

class _NavItemData {
  final AdminScreen screen;
  final IconData icon;
  final String label;

  const _NavItemData({
    required this.screen,
    required this.icon,
    required this.label,
  });
}

class _NavGroup {
  final String? label;
  final List<_NavItemData> items;

  const _NavGroup({this.label, required this.items});
}

const List<_NavGroup> _navGroups = [
  _NavGroup(
    items: [
      _NavItemData(
        screen: AdminScreen.dashboardHome,
        icon: Icons.space_dashboard,
        label: 'Kontrolna ploca',
      ),
    ],
  ),
  _NavGroup(
    label: 'UPRAVLJANJE',
    items: [
      _NavItemData(
        screen: AdminScreen.currentVisitors,
        icon: Icons.directions_run,
        label: 'Trenutno u teretani',
      ),
      _NavItemData(
        screen: AdminScreen.memberships,
        icon: Icons.card_membership,
        label: 'Clanarine',
      ),
      _NavItemData(
        screen: AdminScreen.membershipPackages,
        icon: Icons.inventory_2,
        label: 'Paketi clanarina',
      ),
      _NavItemData(
        screen: AdminScreen.users,
        icon: Icons.people,
        label: 'Korisnici',
      ),
    ],
  ),
  _NavGroup(
    label: 'OSOBLJE',
    items: [
      _NavItemData(
        screen: AdminScreen.trainers,
        icon: Icons.fitness_center,
        label: 'Treneri',
      ),
      _NavItemData(
        screen: AdminScreen.nutritionists,
        icon: Icons.restaurant,
        label: 'Nutricionisti',
      ),
    ],
  ),
  _NavGroup(
    label: 'PRODAVNICA',
    items: [
      _NavItemData(
        screen: AdminScreen.supplements,
        icon: Icons.medication,
        label: 'Suplementi',
      ),
      _NavItemData(
        screen: AdminScreen.categories,
        icon: Icons.category,
        label: 'Kategorije',
      ),
      _NavItemData(
        screen: AdminScreen.suppliers,
        icon: Icons.local_shipping,
        label: 'Dobavljaci',
      ),
      _NavItemData(
        screen: AdminScreen.orders,
        icon: Icons.shopping_bag,
        label: 'Kupovine',
      ),
    ],
  ),
  _NavGroup(
    label: 'SADRZAJ',
    items: [
      _NavItemData(
        screen: AdminScreen.faq,
        icon: Icons.help,
        label: 'FAQ',
      ),
      _NavItemData(
        screen: AdminScreen.reviews,
        icon: Icons.rate_review,
        label: 'Recenzije',
      ),
      _NavItemData(
        screen: AdminScreen.seminars,
        icon: Icons.school,
        label: 'Seminari',
      ),
    ],
  ),
  _NavGroup(
    label: 'ANALITIKA',
    items: [
      _NavItemData(
        screen: AdminScreen.businessReport,
        icon: Icons.trending_up,
        label: 'Biznis izvjestaji',
      ),
      _NavItemData(
        screen: AdminScreen.leaderboard,
        icon: Icons.emoji_events,
        label: 'Rang lista',
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// MAIN DASHBOARD SHELL
// ─────────────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  AdminScreen _selectedScreen = AdminScreen.dashboardHome;
  bool _sidebarCollapsed = false;
  bool? _userToggledCollapse;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onScreenSelected(AdminScreen screen) {
    setState(() => _selectedScreen = screen);
    // Close drawer on mobile after selection
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  void _toggleSidebar() {
    setState(() {
      _sidebarCollapsed = !_sidebarCollapsed;
      _userToggledCollapse = _sidebarCollapsed;
    });
  }

  void _openCommandPalette() {
    showCommandPalette(context, onNavigate: _onScreenSelected);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _openCommandPalette,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(gradient: AppGradients.background),
            child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isMobile = width < 800;
            final isNarrow = width < 1200;

            // Determine collapse state: user override or breakpoint default
            final collapsed = _userToggledCollapse ?? isNarrow;

            if (isMobile) {
              return Scaffold(
                key: GlobalKey<ScaffoldState>(),
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  title: const _Logo(),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _AdminProfileButton(compact: true),
                    ),
                  ],
                ),
                drawer: _Sidebar(
                  selectedScreen: _selectedScreen,
                  onScreenSelected: _onScreenSelected,
                  isCompact: false,
                  isDrawer: true,
                  onToggleCollapse: null,
                ),
                body: SafeArea(
                  child: _ContentArea(
                    selectedScreen: _selectedScreen,
                    onNavigate: _onScreenSelected,
                  ),
                ),
              );
            }

            return SafeArea(
              child: Row(
                children: [
                  _Sidebar(
                    selectedScreen: _selectedScreen,
                    onScreenSelected: _onScreenSelected,
                    isCompact: collapsed,
                    isDrawer: false,
                    onToggleCollapse: _toggleSidebar,
                  ),
                  Expanded(
                    child: _ContentArea(
                      selectedScreen: _selectedScreen,
                      onNavigate: _onScreenSelected,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
    ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SIDEBAR
// ─────────────────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selectedScreen,
    required this.onScreenSelected,
    required this.isCompact,
    required this.isDrawer,
    required this.onToggleCollapse,
  });

  final AdminScreen selectedScreen;
  final void Function(AdminScreen) onScreenSelected;
  final bool isCompact;
  final bool isDrawer;
  final VoidCallback? onToggleCollapse;

  static const double expandedWidth = 260;
  static const double compactWidth = 70;
  static const Color sidebarBg = Color(0xFF1E2235);

  @override
  Widget build(BuildContext context) {
    final showExpanded = isDrawer || !isCompact;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: isDrawer ? expandedWidth : (isCompact ? compactWidth : expandedWidth),
      decoration: const BoxDecoration(
        color: sidebarBg,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          _SidebarHeader(isCompact: !showExpanded),
          const SizedBox(height: 4),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              children: [
                for (final group in _navGroups) ...[
                  if (group.label != null) ...[
                    _SectionLabel(
                      label: group.label!,
                      isCompact: !showExpanded,
                    ),
                  ],
                  for (final item in group.items)
                    _NavItem(
                      icon: item.icon,
                      label: item.label,
                      isSelected: selectedScreen == item.screen,
                      isCompact: !showExpanded,
                      onTap: () => onScreenSelected(item.screen),
                    ),
                ],
              ],
            ),
          ),
          if (onToggleCollapse != null)
            _CollapseToggle(
              isCompact: !showExpanded,
              onToggle: onToggleCollapse!,
            ),
          _AdminProfileSection(isCompact: !showExpanded),
        ],
      ),
    );

    if (isDrawer) {
      return Drawer(
        backgroundColor: sidebarBg,
        child: content,
      );
    }

    return content;
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.isCompact});

  final String label;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Divider(color: AppColors.border, height: 1),
      );
    }

    return ClipRect(
      child: Padding(
        padding: const EdgeInsets.only(left: 14, top: 20, bottom: 8),
        child: Text(label, style: AppTypography.label, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _CollapseToggle extends StatelessWidget {
  const _CollapseToggle({required this.isCompact, required this.onToggle});

  final bool isCompact;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 16,
        vertical: 4,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final effectiveCompact =
                    isCompact || constraints.maxWidth < 100;
                return Row(
                  mainAxisAlignment: effectiveCompact
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    if (!effectiveCompact) const SizedBox(width: 10),
                    Icon(
                      effectiveCompact
                          ? Icons.chevron_right
                          : Icons.chevron_left,
                      color: AppColors.muted,
                      size: 20,
                    ),
                    if (!effectiveCompact) ...[
                      const SizedBox(width: 10),
                      const Text(
                        'Smanji',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 20,
        vertical: 20,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final effectiveCompact = isCompact || constraints.maxWidth < 160;
          return effectiveCompact
              ? const Icon(
                  Icons.fitness_center,
                  color: AppColors.accent,
                  size: 28,
                )
              : const _Logo();
        },
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return const FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fitness_center,
            color: AppColors.accent,
            size: 28,
          ),
          SizedBox(width: 10),
          Text(
            'STRONGHOLD',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isCompact,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isCompact;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // New: subtle tint instead of solid fill
    final bgColor = widget.isSelected
        ? AppColors.accent.withValues(alpha: 0.10)
        : _hover
            ? AppColors.surfaceHover
            : Colors.transparent;

    final textColor = widget.isSelected
        ? Colors.white
        : _hover
            ? Colors.white
            : Colors.white.withValues(alpha: 0.7);

    final iconColor = widget.isSelected
        ? AppColors.accent
        : _hover
            ? AppColors.accent
            : Colors.white.withValues(alpha: 0.7);

    // Left pill indicator width
    final pillWidth = widget.isSelected ? 3.0 : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) => _controller.reverse(),
          onTapCancel: () => _controller.reverse(),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // Left accent pill indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        width: pillWidth,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      if (widget.isSelected) const SizedBox(width: 1),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Use actual width to decide layout, not just
                            // isCompact flag, to avoid overflow during the
                            // sidebar width animation.
                            final effectiveCompact =
                                widget.isCompact || constraints.maxWidth < 80;
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: effectiveCompact ? 0 : 12,
                                vertical: 10,
                              ),
                              child: effectiveCompact
                                  ? Tooltip(
                                      message: widget.label,
                                      preferBelow: false,
                                      child: Center(
                                        child: TweenAnimationBuilder<Color?>(
                                          tween: ColorTween(end: iconColor),
                                          duration: const Duration(
                                              milliseconds: 200),
                                          builder: (context, color, _) => Icon(
                                            widget.icon,
                                            color: color,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        TweenAnimationBuilder<Color?>(
                                          tween: ColorTween(end: iconColor),
                                          duration: const Duration(
                                              milliseconds: 200),
                                          builder: (context, color, _) => Icon(
                                            widget.icon,
                                            color: color,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: widget.isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: textColor,
                                            ),
                                            child: Text(
                                              widget.label,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminProfileSection extends StatelessWidget {
  const _AdminProfileSection({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: _AdminProfileButton(compact: isCompact),
    );
  }
}

class _AdminProfileButton extends StatelessWidget {
  const _AdminProfileButton({required this.compact});

  final bool compact;

  Future<void> _handleLogout(BuildContext context) async {
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
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.card,
      onSelected: (value) async {
        if (value == 'logout') {
          await _handleLogout(context);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, color: Colors.white70, size: 20),
              SizedBox(width: 12),
              Text('Profil', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: AppColors.accent, size: 20),
              SizedBox(width: 12),
              Text('Odjavi se', style: TextStyle(color: AppColors.accent)),
            ],
          ),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final effectiveCompact = compact || constraints.maxWidth < 80;
          return effectiveCompact
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white70,
                    size: 20,
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.person_outline,
                          color: Colors.white70, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Admin',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down,
                          color: Colors.white70, size: 20),
                    ],
                  ),
                );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTENT AREA
// ─────────────────────────────────────────────────────────────────────────────

class _ContentArea extends StatelessWidget {
  const _ContentArea({
    required this.selectedScreen,
    required this.onNavigate,
  });

  final AdminScreen selectedScreen;
  final void Function(AdminScreen) onNavigate;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.03, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<AdminScreen>(selectedScreen),
        child: _buildScreen(),
      ),
    );
  }

  Widget _buildScreen() {
    switch (selectedScreen) {
      case AdminScreen.dashboardHome:
        return DashboardHomeScreen(onNavigate: onNavigate);
      case AdminScreen.currentVisitors:
        return const VisitorsScreen(embedded: true);
      case AdminScreen.memberships:
        return const MembershipsScreen(embedded: true);
      case AdminScreen.membershipPackages:
        return const MembershipPackagesScreen();
      case AdminScreen.users:
        return const UsersScreen();
      case AdminScreen.trainers:
        return const TrainersScreen();
      case AdminScreen.nutritionists:
        return const NutritionistsScreen();
      case AdminScreen.supplements:
        return const SupplementsScreen();
      case AdminScreen.categories:
        return const CategoriesScreen();
      case AdminScreen.suppliers:
        return const SuppliersScreen();
      case AdminScreen.orders:
        return const OrdersScreen();
      case AdminScreen.faq:
        return const FaqScreen();
      case AdminScreen.reviews:
        return const ReviewsScreen();
      case AdminScreen.seminars:
        return const SeminarsScreen();
      case AdminScreen.businessReport:
        return const BusinessReportScreen(embedded: true);
      case AdminScreen.leaderboard:
        return const LeaderboardScreen(embedded: true);
    }
  }
}
