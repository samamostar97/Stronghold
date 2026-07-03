import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/appointments_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/check_in_screen.dart';
import '../screens/cities_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/faq_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/memberships_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/packages_screen.dart';
import '../screens/payments_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/reviews_screen.dart';
import '../screens/seminars_screen.dart';
import '../screens/staff_screen.dart';
import '../screens/suppliers_screen.dart';
import '../screens/supplements_screen.dart';
import '../screens/users_screen.dart';
import '../utils/app_theme.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final Widget screen;

  const _NavItem(this.label, this.icon, this.screen);
}

class _NavSection {
  final String title;
  final List<_NavItem> items;

  const _NavSection(this.title, this.items);
}

/// Zajednicki layout desktop aplikacije - bocna navigacija je JEDNA,
/// svi ekrani se renderuju unutar nje.
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // sekcije se popunjavaju kako ekrani nastaju - bez mrtvih linkova
  static const List<_NavSection> _sections = [
    _NavSection('Analitika', [
      _NavItem('Dashboard', Icons.dashboard_outlined, DashboardScreen()),
      _NavItem('Biznis report', Icons.assessment_outlined, ReportsScreen()),
      _NavItem('Leaderboard', Icons.emoji_events_outlined, LeaderboardScreen()),
    ]),
    _NavSection('Upravljanje', [
      _NavItem('Korisnici', Icons.people_outline, UsersScreen()),
      _NavItem('Članarine', Icons.card_membership_outlined, MembershipsScreen()),
      _NavItem('Uplate', Icons.payments_outlined, PaymentsScreen()),
      _NavItem('Check-in', Icons.login_outlined, CheckInScreen()),
    ]),
    _NavSection('Osoblje', [
      _NavItem('Treneri', Icons.fitness_center_outlined,
          StaffScreen(staffType: 0, singularLabel: 'trener')),
      _NavItem('Nutricionisti', Icons.restaurant_menu_outlined,
          StaffScreen(staffType: 1, singularLabel: 'nutricionista')),
      _NavItem('Termini', Icons.event_outlined, AppointmentsScreen()),
    ]),
    _NavSection('Prodavnica', [
      _NavItem('Suplementi', Icons.medication_outlined, SupplementsScreen()),
      _NavItem('Kategorije', Icons.category_outlined, CategoriesScreen()),
      _NavItem('Dobavljači', Icons.local_shipping_outlined, SuppliersScreen()),
      _NavItem('Narudžbe', Icons.receipt_long_outlined, OrdersScreen()),
    ]),
    _NavSection('Sadržaj', [
      _NavItem('Seminari', Icons.school_outlined, SeminarsScreen()),
      _NavItem('Recenzije', Icons.reviews_outlined, ReviewsScreen()),
      _NavItem('FAQ', Icons.help_outline, FaqScreen()),
      _NavItem('Paketi članarina', Icons.inventory_2_outlined, PackagesScreen()),
      _NavItem('Gradovi', Icons.location_city_outlined, CitiesScreen()),
    ]),
  ];

  int _selectedSection = 0;
  int _selectedItem = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final selected = _sections[_selectedSection].items[_selectedItem];

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 248,
            color: AppTheme.navyDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.fitness_center,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'STRONGHOLD',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      for (var s = 0; s < _sections.length; s++) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
                          child: Text(
                            _sections[s].title.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        for (var i = 0; i < _sections[s].items.length; i++)
                          _sidebarItem(s, i),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white.withValues(alpha: 0.16),
                        child: Text(
                          user?.firstName.isNotEmpty == true
                              ? user!.firstName[0]
                              : '?',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.firstName ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Administrator',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Odjava',
                        icon: Icon(Icons.logout,
                            size: 18, color: Colors.white.withValues(alpha: 0.75)),
                        onPressed: () => context.read<AuthProvider>().logout(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
                  ),
                  child: Text(
                    selected.label,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: selected.screen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(int section, int item) {
    final navItem = _sections[section].items[item];
    final isSelected = _selectedSection == section && _selectedItem == item;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          hoverColor: Colors.white.withValues(alpha: 0.06),
          onTap: () => setState(() {
            _selectedSection = section;
            _selectedItem = item;
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Icon(
                  navItem.icon,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 11),
                Text(
                  navItem.label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.75),
                    fontSize: 13.5,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
