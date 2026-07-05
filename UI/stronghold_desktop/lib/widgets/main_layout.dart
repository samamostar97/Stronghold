import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/appointments_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/check_in_screen.dart';
import '../screens/cities_screen.dart';
import '../screens/faq_screen.dart';
import '../screens/memberships_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/packages_screen.dart';
import '../screens/payments_screen.dart';
import '../screens/reviews_screen.dart';
import '../screens/seminars_screen.dart';
import '../screens/staff_screen.dart';
import '../screens/suppliers_screen.dart';
import '../screens/supplements_screen.dart';
import '../screens/users_screen.dart';

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
          SizedBox(
            width: 240,
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(Icons.fitness_center, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          'Stronghold',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      children: [
                        for (var s = 0; s < _sections.length; s++) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                            child: Text(
                              _sections[s].title.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                          for (var i = 0; i < _sections[s].items.length; i++)
                            ListTile(
                              dense: true,
                              leading: Icon(_sections[s].items[i].icon),
                              title: Text(_sections[s].items[i].label),
                              selected: _selectedSection == s && _selectedItem == i,
                              onTap: () => setState(() {
                                _selectedSection = s;
                                _selectedItem = i;
                              }),
                            ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(user?.firstName ?? ''),
                    trailing: IconButton(
                      tooltip: 'Odjava',
                      icon: const Icon(Icons.logout),
                      onPressed: () => context.read<AuthProvider>().logout(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Text(
                    selected.label,
                    style: Theme.of(context).textTheme.headlineSmall,
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
}
