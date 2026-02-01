import 'package:flutter/material.dart';
import 'package:stronghold_desktop/screens/business_report_screen.dart';
import 'package:stronghold_desktop/screens/category_management_screen.dart';
import 'package:stronghold_desktop/screens/current_visitors_screen.dart';
import 'package:stronghold_desktop/screens/membership_package_management_screen.dart';
import 'package:stronghold_desktop/screens/nutritionist_management_screen.dart';
import 'package:stronghold_desktop/screens/order_management_screen.dart';
import 'package:stronghold_desktop/screens/reviews_management_screen.dart';
import 'package:stronghold_desktop/screens/faq_management_screen.dart';
import 'package:stronghold_desktop/screens/seminar_management_screen.dart';
import 'package:stronghold_desktop/screens/supplements_management_screen.dart';
import 'package:stronghold_desktop/screens/supplier_management_screen.dart';
import 'package:stronghold_desktop/screens/trainer_management_screen.dart';
import 'package:stronghold_desktop/services/token_storage.dart';
import 'package:stronghold_desktop/screens/login_screen.dart';
import 'package:stronghold_desktop/screens/users_management_screen.dart';
import 'package:stronghold_desktop/screens/membership_extension_screen.dart';
import 'package:stronghold_desktop/screens/leaderboard_management_screen.dart';
import '../constants/app_colors.dart';

/// Enum representing all available admin screens
enum AdminScreen {
  currentVisitors,
  membershipExtension,
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

/// Navigation item data for the sidebar
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

/// All navigation items in order
const List<_NavItemData> _navItems = [
  _NavItemData(
    screen: AdminScreen.currentVisitors,
    icon: Icons.directions_run,
    label: 'Trenutno u teretani',
  ),
  _NavItemData(
    screen: AdminScreen.membershipExtension,
    icon: Icons.add_circle_outline,
    label: 'Produžavanje članarine',
  ),
  _NavItemData(
    screen: AdminScreen.membershipPackages,
    icon: Icons.inventory_2_outlined,
    label: 'Upravljanje paketima',
  ),
  _NavItemData(
    screen: AdminScreen.users,
    icon: Icons.person_outline,
    label: 'Upravljanje korisnicima',
  ),
  _NavItemData(
    screen: AdminScreen.trainers,
    icon: Icons.fitness_center,
    label: 'Treneri',
  ),
  _NavItemData(
    screen: AdminScreen.nutritionists,
    icon: Icons.restaurant_menu,
    label: 'Nutricionisti',
  ),
  _NavItemData(
    screen: AdminScreen.supplements,
    icon: Icons.medication_outlined,
    label: 'Suplementi',
  ),
  _NavItemData(
    screen: AdminScreen.categories,
    icon: Icons.category_outlined,
    label: 'Kategorije',
  ),
  _NavItemData(
    screen: AdminScreen.suppliers,
    icon: Icons.local_shipping_outlined,
    label: 'Dobavljači',
  ),
  _NavItemData(
    screen: AdminScreen.orders,
    icon: Icons.shopping_bag_outlined,
    label: 'Kupovine',
  ),
  _NavItemData(
    screen: AdminScreen.faq,
    icon: Icons.help_outline,
    label: 'FAQ',
  ),
  _NavItemData(
    screen: AdminScreen.reviews,
    icon: Icons.rate_review_outlined,
    label: 'Recenzije',
  ),
  _NavItemData(
    screen: AdminScreen.seminars,
    icon: Icons.school_outlined,
    label: 'Seminari',
  ),
  _NavItemData(
    screen: AdminScreen.businessReport,
    icon: Icons.trending_up,
    label: 'Biznis izvještaji',
  ),
  _NavItemData(
    screen: AdminScreen.leaderboard,
    icon: Icons.emoji_events,
    label: 'Rang lista',
  ),
];

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  AdminScreen _selectedScreen = AdminScreen.currentVisitors;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onScreenSelected(AdminScreen screen) {
    setState(() => _selectedScreen = screen);
    // Close drawer on mobile after selection
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: null, // We'll conditionally add this in the builder
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bg1, AppColors.bg2],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isMobile = width < 800;
            final isCompact = width < 1200;

            if (isMobile) {
              // Mobile: Drawer-based sidebar
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
                ),
                body: SafeArea(
                  child: _ContentArea(selectedScreen: _selectedScreen),
                ),
              );
            }

            // Tablet/Desktop: Side-by-side layout
            return SafeArea(
              child: Row(
                children: [
                  _Sidebar(
                    selectedScreen: _selectedScreen,
                    onScreenSelected: _onScreenSelected,
                    isCompact: isCompact,
                    isDrawer: false,
                  ),
                  Expanded(
                    child: _ContentArea(selectedScreen: _selectedScreen),
                  ),
                ],
              ),
            );
          },
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
  });

  final AdminScreen selectedScreen;
  final void Function(AdminScreen) onScreenSelected;
  final bool isCompact;
  final bool isDrawer;

  static const double expandedWidth = 260;
  static const double compactWidth = 70;
  static const Color sidebarBg = Color(0xFF1E2235);

  @override
  Widget build(BuildContext context) {
    final width = isCompact ? compactWidth : expandedWidth;

    final content = Container(
      width: isDrawer ? expandedWidth : width,
      decoration: const BoxDecoration(
        color: sidebarBg,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo/Branding
          if (!isDrawer || isDrawer)
            _SidebarHeader(isCompact: isCompact && !isDrawer),

          const SizedBox(height: 8),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final item in _navItems)
                  _NavItem(
                    icon: item.icon,
                    label: item.label,
                    isSelected: selectedScreen == item.screen,
                    isCompact: isCompact && !isDrawer,
                    onTap: () => onScreenSelected(item.screen),
                  ),
              ],
            ),
          ),

          // Admin profile at bottom
          _AdminProfileSection(isCompact: isCompact && !isDrawer),
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
      child: isCompact
          ? const Icon(
              Icons.fitness_center,
              color: AppColors.accent,
              size: 28,
            )
          : const _Logo(),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return const Row(
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

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
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
    final bgColor = widget.isSelected
        ? AppColors.accent
        : _hover
            ? AppColors.accent.withValues(alpha: 0.15)
            : Colors.transparent;

    final textColor = widget.isSelected
        ? Colors.white
        : _hover
            ? Colors.white
            : Colors.white.withValues(alpha: 0.7);

    final iconColor = widget.isSelected
        ? Colors.white
        : _hover
            ? AppColors.accent
            : Colors.white.withValues(alpha: 0.7);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isCompact ? 0 : 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: widget.isCompact
                      ? Tooltip(
                          message: widget.label,
                          preferBelow: false,
                          child: Center(
                            child: TweenAnimationBuilder<Color?>(
                              tween: ColorTween(end: iconColor),
                              duration: const Duration(milliseconds: 200),
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
                              duration: const Duration(milliseconds: 200),
                              builder: (context, color, _) => Icon(
                                widget.icon,
                                color: color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
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
      child: compact
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.white70, size: 20),
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
                  Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTENT AREA
// ─────────────────────────────────────────────────────────────────────────────

class _ContentArea extends StatelessWidget {
  const _ContentArea({required this.selectedScreen});

  final AdminScreen selectedScreen;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Fade + subtle slide from right
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.03, 0), // Subtle slide from right
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
      case AdminScreen.currentVisitors:
        return const CurrentVisitorsScreen(embedded: true);
      case AdminScreen.membershipExtension:
        return const MembershipManagementScreen(embedded: true);
      case AdminScreen.membershipPackages:
        return const MembershipPackageManagementScreen(embedded: true);
      case AdminScreen.users:
        return const UsersManagementScreen(embedded: true);
      case AdminScreen.trainers:
        return const TrainerManagementScreen(embedded: true);
      case AdminScreen.nutritionists:
        return const NutritionistManagementScreen(embedded: true);
      case AdminScreen.supplements:
        return const SupplementsManagementScreen(embedded: true);
      case AdminScreen.categories:
        return const CategoryManagementScreen(embedded: true);
      case AdminScreen.suppliers:
        return const SupplierManagementScreen(embedded: true);
      case AdminScreen.orders:
        return const OrderManagementScreen(embedded: true);
      case AdminScreen.faq:
        return const FaqManagementScreen(embedded: true);
      case AdminScreen.reviews:
        return const ReviewsManagementScreen(embedded: true);
      case AdminScreen.seminars:
        return const SeminarManagementScreen(embedded: true);
      case AdminScreen.businessReport:
        return const BusinessReportScreen(embedded: true);
      case AdminScreen.leaderboard:
        return const LeaderboardManagementScreen(embedded: true);
    }
  }
}
