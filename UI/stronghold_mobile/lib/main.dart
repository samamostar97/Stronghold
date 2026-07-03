import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/appointments_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/faq_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/reviews_provider.dart';
import 'providers/seminars_provider.dart';
import 'providers/shop_provider.dart';
import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';
import 'utils/api_client.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final apiClient = ApiClient();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => ProfileProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => NotificationsProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => ShopProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => AppointmentsProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => SeminarsProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => FaqProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => ReviewsProvider(apiClient)),
      ],
      child: const StrongholdMobileApp(),
    ),
  );
}

class StrongholdMobileApp extends StatelessWidget {
  const StrongholdMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stronghold',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) =>
            auth.isLoggedIn ? const ShellScreen() : const LoginScreen(),
      ),
    );
  }
}
