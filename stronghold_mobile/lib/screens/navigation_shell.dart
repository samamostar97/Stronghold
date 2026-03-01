import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_bottom_nav.dart';

/// Provider to allow child widgets to detect tab switches
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class NavigationShellWrapper extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const NavigationShellWrapper({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sync the current tab index to the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = ref.read(bottomNavIndexProvider);
      if (current != navigationShell.currentIndex) {
        ref.read(bottomNavIndexProvider.notifier).state =
            navigationShell.currentIndex;
      }
    });

    return PopScope(
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: navigationShell,
        bottomNavigationBar: AppBottomNav(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
        ),
      ),
    );
  }
}
