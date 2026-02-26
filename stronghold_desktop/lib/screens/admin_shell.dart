import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:stronghold_core/stronghold_core.dart'
    show ParticleBackground, TokenStorage;
import '../constants/app_colors.dart';
import '../providers/notification_provider.dart';
import '../widgets/shell/admin_top_bar.dart';
import '../widgets/shell/app_sidebar.dart';
import '../widgets/shell/command_palette.dart';
import '../widgets/shared/success_animation.dart';

const _idToPath = <String, String>{
  'dashboardHome': '/dashboard',
  'currentVisitors': '/visitors',
  'memberships': '/memberships',
  'membershipPackages': '/membership-packages',
  'users': '/users',
  'trainers': '/trainers',
  'nutritionists': '/nutritionists',
  'appointments': '/appointments',
  'supplements': '/supplements',
  'categories': '/categories',
  'suppliers': '/suppliers',
  'orders': '/orders',
  'faq': '/faq',
  'reviews': '/reviews',
  'seminars': '/seminars',
  'businessReport': '/reports',
  'leaderboard': '/leaderboard',
};

const _pathTitles = <String, String>{
  '/dashboard': 'Kontrolna ploca',
  '/visitors': 'Trenutno u teretani',
  '/memberships': 'Clanarine',
  '/membership-packages': 'Paketi clanarina',
  '/users': 'Korisnici',
  '/trainers': 'Treneri',
  '/nutritionists': 'Nutricionisti',
  '/appointments': 'Termini',
  '/supplements': 'Suplementi',
  '/categories': 'Kategorije',
  '/suppliers': 'Dobavljaci',
  '/orders': 'Kupovine',
  '/faq': 'FAQ',
  '/reviews': 'Recenzije',
  '/seminars': 'Seminari',
  '/reports': 'Biznis izvjestaji',
  '/leaderboard': 'Rang lista',
};

final _pathToId = {
  for (final e in _idToPath.entries) e.value: e.key,
};

String _activeIdFromLocation(String location) {
  return _pathToId[location] ?? 'dashboardHome';
}

const _navGroups = [
  NavGroup(items: [
    NavItem(
        id: 'dashboardHome',
        label: 'Kontrolna ploca',
        icon: LucideIcons.layoutDashboard),
  ]),
  NavGroup(label: 'UPRAVLJANJE', items: [
    NavItem(
        id: 'currentVisitors',
        label: 'Trenutno u teretani',
        icon: LucideIcons.activity),
    NavItem(
        id: 'memberships',
        label: 'Clanarine',
        icon: LucideIcons.creditCard),
    NavItem(
        id: 'membershipPackages',
        label: 'Paketi clanarina',
        icon: LucideIcons.package2),
    NavItem(id: 'users', label: 'Korisnici', icon: LucideIcons.users),
  ]),
  NavGroup(label: 'OSOBLJE', items: [
    NavItem(id: 'trainers', label: 'Treneri', icon: LucideIcons.dumbbell),
    NavItem(
        id: 'nutritionists',
        label: 'Nutricionisti',
        icon: LucideIcons.apple),
    NavItem(
        id: 'appointments',
        label: 'Termini',
        icon: LucideIcons.calendarCheck),
  ]),
  NavGroup(label: 'PRODAVNICA', items: [
    NavItem(id: 'supplements', label: 'Suplementi', icon: LucideIcons.pill),
    NavItem(id: 'categories', label: 'Kategorije', icon: LucideIcons.tag),
    NavItem(id: 'suppliers', label: 'Dobavljaci', icon: LucideIcons.truck),
    NavItem(
        id: 'orders', label: 'Kupovine', icon: LucideIcons.shoppingBag),
  ]),
  NavGroup(label: 'SADRZAJ', items: [
    NavItem(id: 'faq', label: 'FAQ', icon: LucideIcons.helpCircle),
    NavItem(id: 'reviews', label: 'Recenzije', icon: LucideIcons.star),
    NavItem(
        id: 'seminars',
        label: 'Seminari',
        icon: LucideIcons.graduationCap),
  ]),
  NavGroup(label: 'ANALITIKA', items: [
    NavItem(
        id: 'businessReport',
        label: 'Biznis izvjestaji',
        icon: LucideIcons.trendingUp),
    NavItem(
        id: 'leaderboard', label: 'Rang lista', icon: LucideIcons.trophy),
  ]),
];

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  bool _collapsed = false;
  bool? _userCollapse;
  int _prevUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).startPolling();
    });
  }

  void _toggleCollapse() {
    setState(() {
      _collapsed = !_collapsed;
      _userCollapse = _collapsed;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await TokenStorage.clear();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final activeId = _activeIdFromLocation(location);
    final title = _pathTitles[location] ?? '';

    // Listen for new notifications and show toast
    ref.listen<NotificationState>(notificationProvider, (prev, next) {
      if (prev != null &&
          next.unreadCount > _prevUnreadCount &&
          _prevUnreadCount >= 0) {
        final diff = next.unreadCount - _prevUnreadCount;
        if (diff > 0 && prev.unreadCount > 0) {
          showSuccessAnimation(context,
              message: 'Nova obavjestenja ($diff)');
        }
      }
      _prevUnreadCount = next.unreadCount;
    });

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
            showCommandPalette(context),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppColors.deepBlue,
          body: Stack(
            children: [
              // Full-screen gradient + particles
              Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.heroGradient),
              ),
              const ParticleBackground(
                particleColor: Color(0xFF38BDF8),
                particleCount: 60,
                connectDistance: 130,
              ),
              // App content
              LayoutBuilder(
                builder: (context, constraints) {
                  final collapsed =
                      _userCollapse ?? constraints.maxWidth < 1200;

                  return SafeArea(
                    child: Row(
                      children: [
                        AppSidebar(
                          groups: _navGroups,
                          activeId: activeId,
                          onSelect: (id) {
                            final path = _idToPath[id];
                            if (path != null) context.go(path);
                          },
                          collapsed: collapsed,
                          onToggleCollapse: _toggleCollapse,
                          onLogout: () => _logout(context),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              AdminTopBar(
                                title: title,
                                onNavigateToOrders: () =>
                                    context.go('/orders'),
                              ),
                              Expanded(child: widget.child),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
