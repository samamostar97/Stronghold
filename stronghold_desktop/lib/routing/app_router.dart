import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/admin_shell.dart';
import '../screens/business_report_screen.dart';
import '../screens/dashboard_home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/reviews_screen.dart';
import '../screens/seminars_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/staff_screen.dart';
import '../screens/supplements_screen.dart';
import '../screens/users_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/visitors_screen.dart';

Page<void> _fadeSlidePage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.03, 0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const DashboardHomeScreen(), state),
          ),
          GoRoute(
            path: '/visitors',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const VisitorsScreen(), state),
          ),
          GoRoute(
            path: '/users',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const UsersScreen(), state),
          ),
          GoRoute(
            path: '/users/:id',
            pageBuilder: (context, state) {
              final userId = int.parse(state.pathParameters['id']!);
              return _fadeSlidePage(
                UserProfileScreen(userId: userId),
                state,
              );
            },
          ),
          GoRoute(
            path: '/staff',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const StaffScreen(), state),
          ),
          GoRoute(
            path: '/supplements',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const SupplementsScreen(), state),
          ),
          GoRoute(
            path: '/orders',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const OrdersScreen(), state),
          ),
          GoRoute(
            path: '/reviews',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const ReviewsScreen(), state),
          ),
          GoRoute(
            path: '/seminars',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const SeminarsScreen(), state),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const BusinessReportScreen(), state),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const SettingsScreen(), state),
          ),
        ],
      ),
    ],
  );
});
