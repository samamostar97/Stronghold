import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/notifications_provider.dart';
import 'appointments_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'seminars_screen.dart';
import 'shop_screen.dart';

/// Glavni okvir aplikacije nakon prijave - donja navigacija.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  /// Prebacivanje na drugi tab iz child ekrana (npr. Pocetna -> Termini).
  static void switchTab(BuildContext context, int index) {
    context.findAncestorStateOfType<_ShellScreenState>()?._selectTab(index);
  }

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _selectedIndex = 0;

  void _selectTab(int index) => setState(() => _selectedIndex = index);

  static const _screens = [
    HomeScreen(),
    ShopScreen(),
    AppointmentsScreen(),
    SeminarsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // auto-refresh notifikacija pollingom dok je korisnik prijavljen
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<NotificationsProvider>().startPolling(),
    );
  }

  @override
  void deactivate() {
    context.read<NotificationsProvider>().stopPolling();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Početna',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.storefront_outlined),
            ),
            selectedIcon: const Icon(Icons.storefront),
            label: 'Prodavnica',
          ),
          const NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Termini',
          ),
          const NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Seminari',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
