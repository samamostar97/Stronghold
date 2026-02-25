import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/admin_shell.dart';
import '../screens/appointments_screen.dart';
import '../screens/business_report_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/dashboard_home_screen.dart';
import '../screens/faq_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/membership_packages_screen.dart';
import '../screens/memberships_screen.dart';
import '../screens/nutritionists_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/reviews_screen.dart';
import '../screens/seminars_screen.dart';
import '../screens/supplements_screen.dart';
import '../screens/suppliers_screen.dart';
import '../screens/trainers_screen.dart';
import '../screens/users_screen.dart';
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
            path: '/memberships',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const MembershipsScreen(), state),
          ),
          GoRoute(
            path: '/membership-packages',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const MembershipPackagesScreen(), state),
          ),
          GoRoute(
            path: '/users',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const UsersScreen(), state),
          ),
          GoRoute(
            path: '/trainers',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const TrainersScreen(), state),
          ),
          GoRoute(
            path: '/nutritionists',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const NutritionistsScreen(), state),
          ),
          GoRoute(
            path: '/appointments',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const AppointmentsScreen(), state),
          ),
          GoRoute(
            path: '/supplements',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const SupplementsScreen(), state),
          ),
          GoRoute(
            path: '/categories',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const CategoriesScreen(), state),
          ),
          GoRoute(
            path: '/suppliers',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const SuppliersScreen(), state),
          ),
          GoRoute(
            path: '/orders',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const OrdersScreen(), state),
          ),
          GoRoute(
            path: '/faq',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const FaqScreen(), state),
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
            path: '/leaderboard',
            pageBuilder: (context, state) =>
                _fadeSlidePage(const LeaderboardScreen(), state),
          ),
        ],
      ),
    ],
  );
});
