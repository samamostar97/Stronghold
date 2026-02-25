import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'package:stronghold_desktop/constants/app_theme.dart';
import 'package:stronghold_desktop/routing/app_router.dart';

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
