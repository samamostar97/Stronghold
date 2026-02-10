import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import 'home_screen.dart';
import 'supplement_shop_screen.dart';
import 'profile_settings_screen.dart';

/// Provider to allow child widgets to switch bottom nav tab
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class NavigationShell extends ConsumerWidget {
  const NavigationShell({super.key});

  static const _screens = <Widget>[
    HomeScreen(),
    SupplementShopScreen(),
    ProfileSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && currentIndex != 0) {
          ref.read(bottomNavIndexProvider.notifier).state = 0;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: currentIndex,
          onTap: (index) => ref.read(bottomNavIndexProvider.notifier).state = index,
        ),
      ),
    );
  }
}
