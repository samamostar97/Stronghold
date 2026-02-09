import 'package:flutter/material.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/business_report_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/dashboard_home_screen.dart';
import '../screens/faq_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/membership_packages_screen.dart';
import '../screens/memberships_screen.dart';
import '../screens/appointments_screen.dart';
import '../screens/nutritionists_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/reviews_screen.dart';
import '../screens/seminars_screen.dart';
import '../screens/supplements_screen.dart';
import '../screens/suppliers_screen.dart';
import '../screens/trainers_screen.dart';
import '../screens/users_screen.dart';
import '../screens/visitors_screen.dart';

/// Animated content area that switches between admin screens.
class AdminContentArea extends StatelessWidget {
  const AdminContentArea({
    super.key,
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
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.03, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
                parent: animation, curve: Curves.easeOutCubic)),
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
      case AdminScreen.appointments:
        return const AppointmentsScreen();
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
