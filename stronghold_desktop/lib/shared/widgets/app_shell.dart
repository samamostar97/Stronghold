import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/notifications/providers/notification_provider.dart';

class NavItem {
  final String label;
  final IconData icon;
  final String route;
  final List<TabItem> tabs;

  const NavItem({
    required this.label,
    required this.icon,
    required this.route,
    this.tabs = const [],
  });
}

class TabItem {
  final String label;
  final String route;

  const TabItem({required this.label, required this.route});
}

final sidebarItems = [
  const NavItem(
    label: 'Kontrolna Ploca',
    icon: Icons.dashboard_outlined,
    route: '/dashboard',
  ),
  const NavItem(
    label: 'Korisnici',
    icon: Icons.people_outline,
    route: '/users',
    tabs: [
      TabItem(label: 'Korisnici', route: '/users'),
      TabItem(label: 'Posjete Teretani', route: '/users/visits'),
      TabItem(label: 'Rang Lista', route: '/users/leaderboard'),
    ],
  ),
  const NavItem(
    label: 'Clanarine',
    icon: Icons.card_membership_outlined,
    route: '/memberships',
    tabs: [
      TabItem(label: 'Aktivne clanarine', route: '/memberships'),
      TabItem(label: 'Historija clanarina', route: '/memberships/history'),
      TabItem(label: 'Paketi clanarina', route: '/memberships/packages'),
    ],
  ),
  const NavItem(
    label: 'Osoblje',
    icon: Icons.badge_outlined,
    route: '/staff',
    tabs: [
      TabItem(label: 'Osoblje', route: '/staff'),
      TabItem(label: 'Termini', route: '/staff/appointments'),
      TabItem(label: 'Historija termina', route: '/staff/appointments/history'),
    ],
  ),
  const NavItem(
    label: 'Proizvodi',
    icon: Icons.inventory_2_outlined,
    route: '/products',
    tabs: [
      TabItem(label: 'Proizvodi', route: '/products'),
      TabItem(label: 'Kategorije', route: '/products/categories'),
      TabItem(label: 'Dobavljaci', route: '/products/suppliers'),
    ],
  ),
  const NavItem(
    label: 'Narudzbe',
    icon: Icons.shopping_bag_outlined,
    route: '/orders',
    tabs: [
      TabItem(label: 'Narudzbe', route: '/orders'),
      TabItem(label: 'Historija narudzbi', route: '/orders/history'),
    ],
  ),
  const NavItem(
    label: 'Izvjestaji',
    icon: Icons.bar_chart_outlined,
    route: '/reports',
    tabs: [
      TabItem(label: 'Prihodi', route: '/reports'),
      TabItem(label: 'Korisnici', route: '/reports/users'),
      TabItem(label: 'Proizvodi', route: '/reports/products'),
      TabItem(label: 'Termini', route: '/reports/appointments'),
    ],
  ),
  const NavItem(
    label: 'Evidencija',
    icon: Icons.history_outlined,
    route: '/audit',
  ),
];

class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;
  String? _prevRoute;
  // 0 = no transition, -1 = slide left, 1 = slide right
  int _slideDirection = 0;
  bool _isSidebarNav = false;

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (var i = sidebarItems.length - 1; i >= 0; i--) {
      if (location.startsWith(sidebarItems[i].route)) return i;
    }
    return 0;
  }

  String? _getActiveTabRoute(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final item = sidebarItems[_selectedIndex];
    for (final tab in item.tabs) {
      if (location == tab.route) return tab.route;
    }
    return item.tabs.isNotEmpty ? item.tabs.first.route : null;
  }

  int _getTabIndex(String? route) {
    if (route == null) return 0;
    final item = sidebarItems[_selectedIndex];
    for (var i = 0; i < item.tabs.length; i++) {
      if (item.tabs[i].route == route) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final newIndex = _getSelectedIndex(context);
    final currentRoute = GoRouterState.of(context).uri.toString();

    // Determine transition type
    if (newIndex != _selectedIndex) {
      _isSidebarNav = true;
      _slideDirection = 0;
    } else if (_prevRoute != null && _prevRoute != currentRoute) {
      _isSidebarNav = false;
      final prevTabIdx = _getTabIndex(_prevRoute);
      final newTabIdx = _getTabIndex(currentRoute);
      _slideDirection = newTabIdx > prevTabIdx ? 1 : -1;
    }

    _selectedIndex = newIndex;
    _prevRoute = currentRoute;

    final currentItem = sidebarItems[_selectedIndex];
    final activeTabRoute = _getActiveTabRoute(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar
          _Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              context.go(sidebarItems[index].route);
            },
            onLogout: () async {
              await ref.read(authStateProvider.notifier).logout();
            },
            adminName:
                ref.watch(authStateProvider).adminName ?? 'Admin',
          ),

          // Content area with grid
          Expanded(
            child: Stack(
              children: [
                // Grid pattern on background
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GridPatternPainter(),
                  ),
                ),
                // Content
                Column(
                  children: [
                    _TopBar(
                      tabs: currentItem.tabs,
                      activeRoute: activeTabRoute,
                      onTabSelected: (route) => context.go(route),
                      unreadCount:
                          ref.watch(unreadCountProvider).value ?? 0,
                    ),
                    Expanded(
                      child: _PageTransition(
                        routeKey: currentRoute,
                        isSidebarNav: _isSidebarNav,
                        slideDirection: _slideDirection,
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onLogout;
  final String adminName;

  const _Sidebar({
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
    required this.adminName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.sidebar,
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  height: 36,
                  child: CustomPaint(painter: _MiniShieldPainter()),
                ),
                const SizedBox(width: 12),
                Text(
                  'STRONGHOLD',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 24, right: 0),
            child: Divider(
              color: Colors.white.withValues(alpha: 0.06),
              height: 1,
            ),
          ),

          const SizedBox(height: 8),

          // Nav items — no horizontal padding on container, items handle their own
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: sidebarItems.length,
              itemBuilder: (context, index) {
                final item = sidebarItems[index];
                final isSelected = index == selectedIndex;

                return _SidebarNavItem(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onItemSelected(index),
                );
              },
            ),
          ),

          // Admin card
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 0),
            child: Divider(
              color: Colors.white.withValues(alpha: 0.06),
              height: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminName,
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Administrator',
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onLogout,
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                  tooltip: 'Odjavi se',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatefulWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _hovering = false;

  @override
  void didUpdateWidget(covariant _SidebarNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      _hovering = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSelected) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(opacity: value, child: child);
        },
        child: Column(
          children: [
            // Top notch — sidebar color with bottom-right curve reveals background
            Container(
              height: 20,
              color: AppColors.background,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.sidebar,
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(20)),
                ),
              ),
            ),

            // Active item — background color matches content
            Container(
              color: AppColors.background,
              padding:
                  const EdgeInsets.only(left: 12),
              child: InkWell(
                onTap: widget.onTap,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(widget.item.icon,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(widget.item.label,
                          style: AppTextStyles.sidebarItemActive),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom notch — sidebar color with top-right curve reveals background
            Container(
              height: 20,
              color: AppColors.background,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.sidebar,
                  borderRadius:
                      BorderRadius.only(topRight: Radius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Inactive item
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _hovering
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(widget.item.icon,
                  color: _hovering
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  size: 20),
              const SizedBox(width: 12),
              Text(
                widget.item.label,
                style: _hovering
                    ? AppTextStyles.sidebarItem
                        .copyWith(color: AppColors.textPrimary)
                    : AppTextStyles.sidebarItem,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageTransition extends StatefulWidget {
  final String routeKey;
  final bool isSidebarNav;
  final int slideDirection;
  final Widget child;

  const _PageTransition({
    required this.routeKey,
    required this.isSidebarNav,
    required this.slideDirection,
    required this.child,
  });

  @override
  State<_PageTransition> createState() => _PageTransitionState();
}

class _PageTransitionState extends State<_PageTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_controller);
    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _PageTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.routeKey != oldWidget.routeKey) {
      if (widget.isSidebarNav) {
        _slideAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: Offset.zero,
        ).animate(_controller);
      } else {
        _slideAnimation = Tween<Offset>(
          begin: Offset(widget.slideDirection * 0.05, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ));
      }

      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

class _MiniShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final shieldPath = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.15)
      ..lineTo(w, h * 0.55)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.55)
      ..lineTo(0, h * 0.15)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.3),
          AppColors.primary.withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(shieldPath, fillPaint);

    final borderPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(shieldPath, borderPaint);

    final linePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final chevronPath = Path()
      ..moveTo(w * 0.28, h * 0.3)
      ..lineTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.72, h * 0.3);
    canvas.drawPath(chevronPath, linePaint);

    canvas.drawLine(
      Offset(w * 0.5, h * 0.5),
      Offset(w * 0.5, h * 0.7),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopBar extends StatelessWidget {
  final List<TabItem> tabs;
  final String? activeRoute;
  final ValueChanged<String> onTabSelected;
  final int unreadCount;

  const _TopBar({
    required this.tabs,
    required this.activeRoute,
    required this.onTabSelected,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20),
      child: Row(
        children: [
          if (tabs.isNotEmpty)
            Expanded(
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.sidebar,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < tabs.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        _TabButton(
                          label: tabs[i].label,
                          isActive: tabs[i].route == activeRoute,
                          onTap: () => onTabSelected(tabs[i].route),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          else
            const Spacer(),

          _NotificationBell(unreadCount: unreadCount),
        ],
      ),
    );
  }
}

class _TabButton extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.primary.withValues(alpha: 0.1)
                : _hovering
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.label,
            style:
                widget.isActive ? AppTextStyles.tabActive : AppTextStyles.tab,
          ),
        ),
      ),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NotificationBell extends StatelessWidget {
  final int unreadCount;

  const _NotificationBell({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    final count = unreadCount;

    return Stack(
      children: [
        IconButton(
          onPressed: () {
            // TODO: open notifications panel
          },
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          tooltip: 'Notifikacije',
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
