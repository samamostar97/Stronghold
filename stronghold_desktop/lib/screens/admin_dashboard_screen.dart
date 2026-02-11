import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../providers/notification_provider.dart';
import '../widgets/admin_content_area.dart';
import '../widgets/admin_top_bar.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/command_palette.dart';
import '../widgets/success_animation.dart';

/// All available admin screens.
enum AdminScreen {
  dashboardHome,
  currentVisitors,
  memberships,
  membershipPackages,
  users,
  trainers,
  nutritionists,
  appointments,
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
    NavItem(id: 'appointments', label: 'Termini',
        icon: LucideIcons.calendarCheck),
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

const _screenTitles = <AdminScreen, String>{
  AdminScreen.dashboardHome: 'Kontrolna ploca',
  AdminScreen.currentVisitors: 'Trenutno u teretani',
  AdminScreen.memberships: 'Clanarine',
  AdminScreen.membershipPackages: 'Paketi clanarina',
  AdminScreen.users: 'Korisnici',
  AdminScreen.trainers: 'Treneri',
  AdminScreen.nutritionists: 'Nutricionisti',
  AdminScreen.appointments: 'Termini',
  AdminScreen.supplements: 'Suplementi',
  AdminScreen.categories: 'Kategorije',
  AdminScreen.suppliers: 'Dobavljaci',
  AdminScreen.orders: 'Kupovine',
  AdminScreen.faq: 'FAQ',
  AdminScreen.reviews: 'Recenzije',
  AdminScreen.seminars: 'Seminari',
  AdminScreen.businessReport: 'Biznis izvjestaji',
  AdminScreen.leaderboard: 'Rang lista',
};

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  AdminScreen _selected = AdminScreen.dashboardHome;
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
    // Listen for new notifications and show toast
    ref.listen<NotificationState>(notificationProvider, (prev, next) {
      if (prev != null && next.unreadCount > _prevUnreadCount && _prevUnreadCount >= 0) {
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
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          AdminTopBar(
                            title: _screenTitles[_selected] ?? '',
                            onNavigateToOrders: () =>
                                setState(() => _selected = AdminScreen.orders),
                          ),
                          Expanded(
                            child: AdminContentArea(
                              selectedScreen: _selected,
                              onNavigate: (s) =>
                                  setState(() => _selected = s),
                            ),
                          ),
                        ],
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

