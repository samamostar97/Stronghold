import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/orders/screens/order_history_screen.dart';
import '../../features/staff/screens/staff_screen.dart';
import '../../features/staff/screens/appointments_screen.dart';
import '../../features/staff/screens/appointment_history_screen.dart';
import '../../features/gym/screens/active_visits_screen.dart';
import '../../features/gym/screens/visit_history_screen.dart';
import '../../features/memberships/screens/active_memberships_screen.dart';
import '../../features/memberships/screens/membership_history_screen.dart';
import '../../features/memberships/screens/membership_packages_screen.dart';
import '../../features/products/screens/products_screen.dart';
import '../../features/products/screens/categories_screen.dart';
import '../../features/products/screens/suppliers_screen.dart';
import '../../features/users/screens/leaderboard_screen.dart';
import '../../features/users/screens/users_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/placeholder_page.dart';

// Listenable that notifies GoRouter when auth state changes
class _AuthNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  set isAuthenticated(bool value) {
    if (_isAuthenticated != value) {
      _isAuthenticated = value;
      notifyListeners();
    }
  }
}

final _authNotifierProvider = Provider<_AuthNotifier>((ref) {
  final notifier = _AuthNotifier();
  ref.listen(authStateProvider, (prev, next) {
    notifier.isAuthenticated = next.isAuthenticated;
  });
  return notifier;
});

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(_authNotifierProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isLoggedIn = authNotifier.isAuthenticated;
      final isLoginPage = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoginPage) return '/login';
      if (isLoggedIn && isLoginPage) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),

          // Korisnici group
          GoRoute(
            path: '/users',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: UsersScreen(),
            ),
          ),
          GoRoute(
            path: '/users/leaderboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LeaderboardScreen(),
            ),
          ),

          // Teretana group
          GoRoute(
            path: '/gym',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ActiveVisitsScreen(),
            ),
          ),
          GoRoute(
            path: '/gym/history',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VisitHistoryScreen(),
            ),
          ),

          // Clanarine group
          GoRoute(
            path: '/memberships',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ActiveMembershipsScreen(),
            ),
          ),
          GoRoute(
            path: '/memberships/history',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MembershipHistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/memberships/packages',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MembershipPackagesScreen(),
            ),
          ),

          // Osoblje group
          GoRoute(
            path: '/staff',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StaffScreen(),
            ),
          ),
          GoRoute(
            path: '/staff/appointments',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AppointmentsScreen(),
            ),
          ),
          GoRoute(
            path: '/staff/appointments/history',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AppointmentHistoryScreen(),
            ),
          ),

          // Proizvodi group
          GoRoute(
            path: '/products',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProductsScreen(),
            ),
          ),
          GoRoute(
            path: '/products/categories',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CategoriesScreen(),
            ),
          ),
          GoRoute(
            path: '/products/suppliers',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SuppliersScreen(),
            ),
          ),

          // Narudzbe
          GoRoute(
            path: '/orders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OrdersScreen(),
            ),
          ),
          GoRoute(
            path: '/orders/history',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OrderHistoryScreen(),
            ),
          ),

          // Izvjestaji group
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PlaceholderPage(title: 'Izvjestaji - Prihodi'),
            ),
          ),
          GoRoute(
            path: '/reports/users',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PlaceholderPage(title: 'Izvjestaji - Korisnici'),
            ),
          ),
          GoRoute(
            path: '/reports/products',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PlaceholderPage(title: 'Izvjestaji - Proizvodi'),
            ),
          ),
          GoRoute(
            path: '/reports/appointments',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PlaceholderPage(title: 'Izvjestaji - Termini'),
            ),
          ),

          // Evidencija
          GoRoute(
            path: '/audit',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PlaceholderPage(title: 'Evidencija Promjena'),
            ),
          ),
        ],
      ),
    ],
  );
});
