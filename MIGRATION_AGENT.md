# MIGRATION_AGENT.md — Stronghold Architecture Cleanup

## Overview

This document contains step-by-step instructions for migrating the Stronghold Flutter project to a cleaner architecture. The project has 3 components:
- `packages/stronghold_core/` — shared Dart package (models, services, API client)
- `stronghold_desktop/` — Flutter desktop admin app
- `stronghold_mobile/` — Flutter mobile user app

**Goals of this migration:**
1. Group desktop's flat 91-widget folder into feature folders
2. Replace desktop enum-based navigation with GoRouter
3. Replace mobile Navigator.push navigation with GoRouter
4. Move 6 duplicated widgets into `stronghold_core`
5. Add barrel exports to `stronghold_core`

**Rules:**
- Work one phase at a time. Complete each phase fully before starting the next.
- After each phase, verify `flutter analyze` passes with no errors.
- Do NOT change any widget internals, business logic, or provider logic. Only move files and update imports/navigation.
- Preserve all existing functionality. The app should work identically after migration.
- Use the IDE's rename/refactor when possible. If doing manual moves, search-and-replace ALL imports.

---

## Phase 1: Group Desktop Widgets by Feature (stronghold_desktop)

### Goal
Reorganize `lib/widgets/` from a flat 91-file folder into feature-based subfolders.

### Current structure
```
lib/widgets/   ← 91 .dart files, all flat
```

### Target structure
```
lib/widgets/
├── shell/
│   ├── app_sidebar.dart
│   ├── admin_top_bar.dart
│   ├── admin_content_area.dart
│   ├── command_palette.dart
│   └── notification_popup.dart
│
├── login/
│   ├── login_form.dart
│   └── login_branding_panel.dart
│
├── dashboard/
│   ├── dashboard_kpi_row.dart
│   ├── dashboard_sales_chart.dart
│   ├── dashboard_revenue_summary.dart
│   ├── dashboard_quick_actions.dart
│   ├── dashboard_recent_members.dart
│   ├── dashboard_membership_panel.dart
│   ├── dashboard_activity_feed.dart
│   ├── dashboard_activity_panel.dart
│   ├── dashboard_admin_activity_feed.dart
│   └── dashboard_bestseller_card.dart
│
├── visitors/
│   ├── visitors_table.dart
│   └── checkin_dialog.dart
│
├── memberships/
│   ├── memberships_table.dart
│   └── membership_payment_dialog.dart
│
├── membership_packages/
│   ├── membership_packages_table.dart
│   ├── membership_package_add_dialog.dart
│   └── membership_package_edit_dialog.dart
│
├── users/
│   ├── users_table.dart
│   ├── user_add_dialog.dart
│   ├── user_edit_dialog.dart
│   ├── user_detail_drawer.dart
│   ├── member_detail_drawer.dart
│   └── add_member_dialog.dart
│
├── trainers/
│   ├── trainers_table.dart
│   ├── trainer_add_dialog.dart
│   └── trainer_edit_dialog.dart
│
├── nutritionists/
│   ├── nutritionists_table.dart
│   ├── nutritionist_add_dialog.dart
│   └── nutritionist_edit_dialog.dart
│
├── appointments/
│   ├── appointments_table.dart
│   ├── appointment_add_dialog.dart
│   └── appointment_edit_dialog.dart
│
├── supplements/
│   ├── supplements_table.dart
│   ├── supplement_add_dialog.dart
│   └── supplement_edit_dialog.dart
│
├── categories/
│   ├── categories_table.dart
│   └── category_dialog.dart
│
├── suppliers/
│   ├── suppliers_table.dart
│   └── supplier_dialog.dart
│
├── orders/
│   ├── orders_table.dart
│   └── order_details_dialog.dart
│
├── faq/
│   ├── faq_table.dart
│   └── faq_dialog.dart
│
├── reviews/
│   └── reviews_table.dart
│
├── seminars/
│   ├── seminars_table.dart
│   ├── seminar_add_dialog.dart
│   ├── seminar_edit_dialog.dart
│   └── seminar_attendees_dialog.dart
│
├── reports/
│   ├── report_business_tab.dart
│   ├── report_inventory_tab.dart
│   ├── report_membership_tab.dart
│   └── report_export_button.dart
│
├── leaderboard/
│   └── leaderboard_table.dart
│
└── shared/
    ├── crud_list_scaffold.dart
    ├── data_table_widgets.dart
    ├── pagination_controls.dart
    ├── search_input.dart
    ├── shared_admin_header.dart
    ├── dialog_text_field.dart
    ├── date_picker_field.dart
    ├── sort_header.dart
    ├── filter_chip_group.dart
    ├── shimmer_loading.dart
    ├── content_state_display.dart
    ├── animated_counter.dart
    ├── stat_card.dart
    ├── small_button.dart
    ├── hover_icon_button.dart
    ├── back_button.dart
    ├── custom_checkbox.dart
    ├── bar_chart.dart
    ├── horizontal_bar_chart.dart
    ├── mini_bar_chart.dart
    ├── sparkline_chart.dart
    ├── star_rating.dart
    ├── confirm_dialog.dart
    ├── success_animation.dart
    ├── error_animation.dart
    ├── glass_card.dart
    ├── gradient_button.dart
    ├── avatar_widget.dart
    ├── particle_background.dart
    ├── ring_progress.dart
    └── status_pill.dart
```

### Steps

1. Create each subfolder inside `lib/widgets/`
2. Move each file into its corresponding subfolder as listed above
3. After each move, update ALL import statements across the project that reference the moved file.
   - Search the entire `lib/` for `import '../widgets/FILENAME'` or `import 'package:stronghold_desktop/widgets/FILENAME'`
   - Replace with the new path, e.g., `import '../widgets/supplements/supplements_table.dart'` or `import '../widgets/shared/crud_list_scaffold.dart'`
4. The rule for which folder a widget goes into: a widget goes into the feature folder that matches the screen it's used on. If it's used by 2+ screens, it goes into `shared/`.
5. Run `flutter analyze` — fix any broken imports until clean.

### Important notes
- `admin_content_area.dart` goes in `shell/` because it's part of the admin shell layout
- `command_palette.dart` goes in `shell/` — it's a global nav feature
- `notification_popup.dart` goes in `shell/` — it's shown from the top bar
- All `dashboard_*.dart` widgets go in `dashboard/`
- All `report_*.dart` widgets go in `reports/`
- `glass_card.dart`, `gradient_button.dart`, `avatar_widget.dart`, `particle_background.dart`, `ring_progress.dart`, `status_pill.dart` go in `shared/` because they are used across features AND also exist in the mobile app

---

## Phase 2: Add GoRouter to Desktop App (stronghold_desktop)

### Goal
Replace the enum-based `AdminScreen` navigation in `admin_dashboard_screen.dart` with GoRouter. This gives us URL-based navigation, deep linking, and cleaner separation.

### Step 2.1: Add dependency

In `stronghold_desktop/pubspec.yaml`, add:
```yaml
dependencies:
  go_router: ^14.8.1
```

Run `flutter pub get`.

### Step 2.2: Create router file

Create `lib/routing/app_router.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/dashboard_home_screen.dart';
import '../screens/visitors_screen.dart';
import '../screens/memberships_screen.dart';
import '../screens/membership_packages_screen.dart';
import '../screens/users_screen.dart';
import '../screens/trainers_screen.dart';
import '../screens/nutritionists_screen.dart';
import '../screens/appointments_screen.dart';
import '../screens/supplements_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/suppliers_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/faq_screen.dart';
import '../screens/reviews_screen.dart';
import '../screens/seminars_screen.dart';
import '../screens/business_report_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/payment_history_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardHomeScreen()),
          GoRoute(path: '/visitors', builder: (_, __) => const VisitorsScreen()),
          GoRoute(path: '/memberships', builder: (_, __) => const MembershipsScreen()),
          GoRoute(path: '/memberships/payments', builder: (_, __) => const PaymentHistoryScreen()),
          GoRoute(path: '/membership-packages', builder: (_, __) => const MembershipPackagesScreen()),
          GoRoute(path: '/users', builder: (_, __) => const UsersScreen()),
          GoRoute(path: '/trainers', builder: (_, __) => const TrainersScreen()),
          GoRoute(path: '/nutritionists', builder: (_, __) => const NutritionistsScreen()),
          GoRoute(path: '/appointments', builder: (_, __) => const AppointmentsScreen()),
          GoRoute(path: '/supplements', builder: (_, __) => const SupplementsScreen()),
          GoRoute(path: '/categories', builder: (_, __) => const CategoriesScreen()),
          GoRoute(path: '/suppliers', builder: (_, __) => const SuppliersScreen()),
          GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
          GoRoute(path: '/faq', builder: (_, __) => const FaqScreen()),
          GoRoute(path: '/reviews', builder: (_, __) => const ReviewsScreen()),
          GoRoute(path: '/seminars', builder: (_, __) => const SeminarsScreen()),
          GoRoute(path: '/reports', builder: (_, __) => const BusinessReportScreen()),
          GoRoute(path: '/leaderboard', builder: (_, __) => const LeaderboardScreen()),
        ],
      ),
    ],
  );
});
```

### Step 2.3: Create AdminShell widget

Create `lib/screens/admin_shell.dart` — this replaces the current `AdminDashboardScreen`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import '../providers/notification_provider.dart';
import '../widgets/shell/app_sidebar.dart';
import '../widgets/shell/admin_top_bar.dart';
import '../widgets/shell/command_palette.dart';
import '../widgets/shared/success_animation.dart';

/// Map from sidebar nav ID to GoRouter path
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

/// Reverse map: path segment → sidebar ID
String _activeIdFromLocation(String location) {
  for (final entry in _idToPath.entries) {
    if (location == entry.value || location.startsWith('${entry.value}/')) {
      return entry.key;
    }
  }
  return 'dashboardHome';
}

/// Screen titles for top bar
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

// Keep the same nav groups definition from admin_dashboard_screen.dart
const _navGroups = [
  NavGroup(items: [
    NavItem(id: 'dashboardHome', label: 'Kontrolna ploca', icon: LucideIcons.layoutDashboard),
  ]),
  NavGroup(label: 'UPRAVLJANJE', items: [
    NavItem(id: 'currentVisitors', label: 'Trenutno u teretani', icon: LucideIcons.activity),
    NavItem(id: 'memberships', label: 'Clanarine', icon: LucideIcons.creditCard),
    NavItem(id: 'membershipPackages', label: 'Paketi clanarina', icon: LucideIcons.package2),
    NavItem(id: 'users', label: 'Korisnici', icon: LucideIcons.users),
  ]),
  NavGroup(label: 'OSOBLJE', items: [
    NavItem(id: 'trainers', label: 'Treneri', icon: LucideIcons.dumbbell),
    NavItem(id: 'nutritionists', label: 'Nutricionisti', icon: LucideIcons.apple),
    NavItem(id: 'appointments', label: 'Termini', icon: LucideIcons.calendarCheck),
  ]),
  NavGroup(label: 'PRODAVNICA', items: [
    NavItem(id: 'supplements', label: 'Suplementi', icon: LucideIcons.pill),
    NavItem(id: 'categories', label: 'Kategorije', icon: LucideIcons.tag),
    NavItem(id: 'suppliers', label: 'Dobavljaci', icon: LucideIcons.truck),
    NavItem(id: 'orders', label: 'Kupovine', icon: LucideIcons.shoppingBag),
  ]),
  NavGroup(label: 'SADRZAJ', items: [
    NavItem(id: 'faq', label: 'FAQ', icon: LucideIcons.helpCircle),
    NavItem(id: 'reviews', label: 'Recenzije', icon: LucideIcons.star),
    NavItem(id: 'seminars', label: 'Seminari', icon: LucideIcons.graduationCap),
  ]),
  NavGroup(label: 'ANALITIKA', items: [
    NavItem(id: 'businessReport', label: 'Biznis izvjestaji', icon: LucideIcons.trendingUp),
    NavItem(id: 'leaderboard', label: 'Rang lista', icon: LucideIcons.trophy),
  ]),
];

class AdminShell extends ConsumerStatefulWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

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

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final activeId = _activeIdFromLocation(location);
    final title = _pathTitles[location] ?? '';

    // Listen for new notifications and show toast
    ref.listen<NotificationState>(notificationProvider, (prev, next) {
      if (prev != null && next.unreadCount > _prevUnreadCount && _prevUnreadCount >= 0) {
        final diff = next.unreadCount - _prevUnreadCount;
        if (diff > 0 && prev.unreadCount > 0) {
          showSuccessAnimation(context, message: 'Nova obavjestenja ($diff)');
        }
      }
      _prevUnreadCount = next.unreadCount;
    });

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
            showCommandPaletteGoRouter(context),
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
                      activeId: activeId,
                      onSelect: (id) {
                        final path = _idToPath[id];
                        if (path != null) context.go(path);
                      },
                      collapsed: collapsed,
                      onToggleCollapse: _toggleCollapse,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          AdminTopBar(
                            title: title,
                            onNavigateToOrders: () => context.go('/orders'),
                          ),
                          Expanded(
                            // Wrap child in AnimatedSwitcher for smooth transitions
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.03, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                                    child: child,
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey(location),
                                child: widget.child,
                              ),
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

/// GoRouter-compatible command palette launcher.
/// Adapt the existing showCommandPalette to use context.go() instead of onNavigate callback.
void showCommandPaletteGoRouter(BuildContext context) {
  // TODO: Adapt the existing command_palette.dart to accept a
  // void Function(String path) onNavigate instead of void Function(AdminScreen).
  // For now, call the existing one with a wrapper:
  // showCommandPalette(context, onNavigate: (screen) {
  //   final path = _idToPath[screen.name];
  //   if (path != null) context.go(path);
  // });
}
```

### Step 2.4: Update main.dart

Replace `lib/main.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'constants/app_theme.dart';
import 'routing/app_router.dart';

void main() {
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5034',
  );
  ApiConfig.initialize(baseUrl);

  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Stronghold Desktop',
      theme: AppTheme.darkTheme(),
      routerConfig: router,
    );
  }
}
```

### Step 2.5: Update login_form.dart navigation

In `lib/widgets/login/login_form.dart` (or wherever login_form.dart is after Phase 1), find:

```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
);
```

Replace with:

```dart
context.go('/dashboard');
```

Add import: `import 'package:go_router/go_router.dart';`

### Step 2.6: Update DashboardHomeScreen

In `lib/screens/dashboard_home_screen.dart`, the `onNavigate` callback currently receives an `AdminScreen` enum. Change it to use GoRouter:

1. Remove the `onNavigate` parameter
2. Replace all `onNavigate?.call(AdminScreen.xxx)` with `context.go('/path')`

For example:
```dart
// BEFORE
onTap: () => onNavigate?.call(AdminScreen.currentVisitors),

// AFTER
onTap: () => context.go('/visitors'),
```

Do the same for `dashboard_quick_actions.dart` if it uses the `onNavigate` callback.

### Step 2.7: Remove old files

- Delete `lib/screens/admin_dashboard_screen.dart` (replaced by `admin_shell.dart`)
- Delete `lib/widgets/shell/admin_content_area.dart` (no longer needed — GoRouter handles content switching)
- Delete the `AdminScreen` enum (no longer needed)
- Delete `lib/app.dart` if it exists (main.dart handles everything now)

### Step 2.8: Remove `embedded` parameters

Several screens have `embedded` parameters (e.g., `VisitorsScreen(embedded: true)`). With GoRouter, all screens are always embedded in the shell. Remove these parameters and any conditional logic they control (like showing/hiding a back button or app bar).

Screens with `embedded` param: `VisitorsScreen`, `MembershipsScreen`, `BusinessReportScreen`, `LeaderboardScreen`.

### Step 2.9: Update command_palette.dart

The current `showCommandPalette` takes `onNavigate: (AdminScreen) => void`. Update it to take a `BuildContext` and use `context.go()`:

```dart
// BEFORE
void showCommandPalette(BuildContext context, {required void Function(AdminScreen) onNavigate})

// AFTER  
void showCommandPalette(BuildContext context)
// Inside, replace onNavigate(AdminScreen.xxx) with:
// Navigator.pop(context); // close palette
// context.go('/path');
```

### Step 2.10: Verify

Run `flutter analyze` and `flutter run -d windows`. Verify:
- Login → navigates to dashboard
- All sidebar items navigate correctly
- Command palette (Ctrl+K) works
- Dashboard quick action buttons navigate
- Animated transitions still work
- Notification polling still works

---

## Phase 3: Add GoRouter to Mobile App (stronghold_mobile)

### Goal
Replace all `Navigator.push/pushReplacement` calls with GoRouter navigation.

### Step 3.1: Add dependency

In `stronghold_mobile/pubspec.yaml`, add:
```yaml
dependencies:
  go_router: ^14.8.1
```

Run `flutter pub get`.

### Step 3.2: Create router file

Create `lib/routing/app_router.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/login_success_screen.dart';
import '../screens/navigation_shell.dart';
import '../screens/home_screen.dart';
import '../screens/supplement_shop_screen.dart';
import '../screens/profile_settings_screen.dart';
import '../screens/supplement_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/order_history_screen.dart';
import '../screens/address_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/appointment_screen.dart';
import '../screens/book_appointment_screen.dart';
import '../screens/trainer_list_screen.dart';
import '../screens/nutritionist_list_screen.dart';
import '../screens/seminar_screen.dart';
import '../screens/faq_screen.dart';
import '../screens/review_history_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/user_progress_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      // ── Auth (no bottom nav) ──
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/login-success', builder: (_, __) => const LoginSuccessScreen()),

      // ── Main app (with bottom nav shell) ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShellGoRouter(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/shop', builder: (_, __) => const SupplementShopScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileSettingsScreen()),
          ]),
        ],
      ),

      // ── Detail screens (pushed on top, no bottom nav) ──
      GoRoute(
        path: '/shop/:id',
        builder: (_, state) => SupplementDetailScreen(
          supplementId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
      GoRoute(path: '/orders', builder: (_, __) => const OrderHistoryScreen()),
      GoRoute(path: '/address', builder: (_, __) => const AddressScreen()),
      GoRoute(path: '/change-password', builder: (_, __) => const ChangePasswordScreen()),
      GoRoute(path: '/appointments', builder: (_, __) => const AppointmentScreen()),
      GoRoute(path: '/book-appointment', builder: (_, __) => const BookAppointmentScreen()),
      GoRoute(path: '/trainers', builder: (_, __) => const TrainerListScreen()),
      GoRoute(path: '/nutritionists', builder: (_, __) => const NutritionistListScreen()),
      GoRoute(path: '/seminars', builder: (_, __) => const SeminarScreen()),
      GoRoute(path: '/faq', builder: (_, __) => const FaqScreen()),
      GoRoute(path: '/reviews', builder: (_, __) => const ReviewHistoryScreen()),
      GoRoute(path: '/leaderboard', builder: (_, __) => const LeaderboardScreen()),
      GoRoute(path: '/progress', builder: (_, __) => const UserProgressScreen()),
    ],
  );
});
```

### Step 3.3: Create GoRouter-compatible NavigationShell

Create `lib/screens/navigation_shell_gorouter.dart` (or update existing):

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../widgets/app_bottom_nav.dart';

class NavigationShellGoRouter extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const NavigationShellGoRouter({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index),
      ),
    );
  }
}
```

### Step 3.4: Update main.dart

Replace `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'config/stripe_config.dart';
import 'constants/app_colors.dart';
import 'constants/app_theme.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('bs');

  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5034',
  );
  ApiConfig.initialize(baseUrl);
  Stripe.publishableKey = StripeConfig.publishableKey;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: StrongholdApp()));
}

class StrongholdApp extends ConsumerWidget {
  const StrongholdApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Stronghold',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      routerConfig: router,
    );
  }
}
```

### Step 3.5: Replace all Navigator calls

Search the entire `lib/` for `Navigator.push`, `Navigator.pushReplacement`, `Navigator.pushAndRemoveUntil`, and `Navigator.pop`.

**Replace patterns:**

```dart
// BEFORE: Push to detail screen
Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
// AFTER:
context.push('/cart');

// BEFORE: Push with constructor param
Navigator.push(context, MaterialPageRoute(builder: (_) => SupplementDetailScreen(supplement: s)));
// AFTER: (supplement ID passed via path)
context.push('/shop/${s.id}');

// BEFORE: Push replacement (login → home)
Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NavigationShell()));
// AFTER:
context.go('/home');

// BEFORE: Push and remove until (logout)
Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
// AFTER:
context.go('/login');

// BEFORE: Pop (back button)
Navigator.pop(context);
// AFTER:
context.pop();

// BEFORE: Pop until first route
Navigator.of(context).popUntil((r) => r.isFirst);
// AFTER:
context.go('/home');
```

Add `import 'package:go_router/go_router.dart';` to every file where you use `context.go()`, `context.push()`, or `context.pop()`.

**IMPORTANT:** Use `context.go()` for full navigation (replaces entire stack). Use `context.push()` for detail screens that should have a back button. Use `context.pop()` for back buttons.

### Step 3.6: Update SupplementDetailScreen

The current `SupplementDetailScreen` likely receives the full `SupplementResponse` object. With GoRouter, we pass the ID via URL and load the data in the screen:

```dart
class SupplementDetailScreen extends ConsumerWidget {
  final int supplementId; // Changed from SupplementResponse to int
  const SupplementDetailScreen({super.key, required this.supplementId});
  // ... load supplement by ID in build method
}
```

If this is too much work, you can also pass the object via `GoRoute.extra`:
```dart
// In router:
GoRoute(
  path: '/shop/detail',
  builder: (_, state) => SupplementDetailScreen(supplement: state.extra as SupplementResponse),
),
// Navigation:
context.push('/shop/detail', extra: supplement);
```

### Step 3.7: Remove old NavigationShell

Delete the old `navigation_shell.dart` and the `bottomNavIndexProvider` StateProvider (no longer needed — GoRouter's `StatefulShellRoute` manages tab state).

### Step 3.8: Verify

Run `flutter analyze` and `flutter run` on emulator. Verify:
- Login → Register → back works
- Login → Home with bottom nav
- Tab switching preserves state (IndexedStack behavior)
- Shop → product detail → back
- Cart → Checkout flow
- Profile → Change password → back
- All back buttons work
- Logout returns to login

---

## Phase 4: Move Duplicated Widgets to stronghold_core

### Goal
Move 6 widgets that exist in both desktop and mobile into the shared package.

### Duplicated widgets
1. `avatar_widget.dart`
2. `glass_card.dart`
3. `gradient_button.dart`
4. `particle_background.dart`
5. `ring_progress.dart`
6. `status_pill.dart`

### Steps

1. Create `packages/stronghold_core/lib/widgets/` directory
2. Compare the desktop and mobile versions of each widget. Pick the more complete version (usually desktop). If they differ significantly, merge them — keep all features from both.
3. Copy the chosen version into `packages/stronghold_core/lib/widgets/`
4. Add exports to `packages/stronghold_core/lib/stronghold_core.dart`:
   ```dart
   // Widgets
   export 'widgets/avatar_widget.dart';
   export 'widgets/glass_card.dart';
   export 'widgets/gradient_button.dart';
   export 'widgets/particle_background.dart';
   export 'widgets/ring_progress.dart';
   export 'widgets/status_pill.dart';
   ```
5. Delete the local copies from both `stronghold_desktop/lib/widgets/shared/` and `stronghold_mobile/lib/widgets/`
6. Update all imports in both apps to use `package:stronghold_core/stronghold_core.dart` (or the specific widget path)
7. Run `flutter analyze` in all 3 projects.

### Important
- The widgets may import different `AppColors` classes. You'll need to either:
  - (a) Pass colors as parameters instead of importing constants, OR
  - (b) Move the shared color tokens into `stronghold_core` as well

Option (a) is safer and requires less refactoring. For example, if `glass_card.dart` uses `AppColors.surface`, change it to accept a `color` parameter with a default value.

---

## Phase 5: Barrel Exports for stronghold_core

### Goal
Break up the 80+ line `stronghold_core.dart` barrel file into organized sub-barrels.

### Steps

1. Create `lib/api/api.dart`:
   ```dart
   export 'api_client.dart';
   export 'api_config.dart';
   export 'api_exception.dart';
   ```

2. Create `lib/models/models.dart`:
   ```dart
   // Common
   export 'common/paged_result.dart';
   export 'common/date_time_utils.dart';
   export 'common/validation_utils.dart';

   // Filters
   export 'filters/base_query_filter.dart';
   export 'filters/active_member_query_filter.dart';
   // ... all other filters

   // Requests
   export 'requests/login_request.dart';
   // ... all other requests

   // Responses
   export 'responses/auth_response.dart';
   // ... all other responses
   ```

3. Create `lib/services/services.dart`:
   ```dart
   export 'crud_service.dart';
   export 'auth_service.dart';
   // ... all other services
   ```

4. Update `lib/stronghold_core.dart`:
   ```dart
   library stronghold_core;

   export 'api/api.dart';
   export 'models/models.dart';
   export 'services/services.dart';
   export 'storage/token_storage.dart';
   export 'widgets/widgets.dart'; // if Phase 4 done
   ```

5. Run `flutter analyze` in all 3 projects — the public API should be identical.

---

## Verification Checklist

After all phases are complete:

- [ ] `flutter analyze` passes in `stronghold_core` with 0 errors
- [ ] `flutter analyze` passes in `stronghold_desktop` with 0 errors
- [ ] `flutter analyze` passes in `stronghold_mobile` with 0 errors
- [ ] Desktop: Login → Dashboard → all 17 sidebar screens navigate correctly
- [ ] Desktop: Ctrl+K command palette works
- [ ] Desktop: Screen transitions are animated (fade + slide)
- [ ] Desktop: Notification polling works
- [ ] Mobile: Login → Register → Forgot password flow works
- [ ] Mobile: Bottom nav tabs (Home, Shop, Profile) switch correctly
- [ ] Mobile: Tab state is preserved when switching tabs
- [ ] Mobile: Shop → Detail → Back works
- [ ] Mobile: Cart → Checkout flow works
- [ ] Mobile: All back buttons work
- [ ] Mobile: Logout clears state and returns to login
- [ ] No duplicated widget files exist between desktop and mobile
