import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/appointments_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/categories_provider.dart';
import 'providers/cities_provider.dart';
import 'providers/faq_provider.dart';
import 'providers/memberships_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/packages_provider.dart';
import 'providers/payments_provider.dart';
import 'providers/reviews_provider.dart';
import 'providers/seminars_provider.dart';
import 'providers/staff_provider.dart';
import 'providers/suppliers_provider.dart';
import 'providers/supplements_provider.dart';
import 'providers/users_provider.dart';
import 'providers/visits_provider.dart';
import 'screens/login_screen.dart';
import 'utils/api_client.dart';
import 'widgets/main_layout.dart';

void main() {
  final apiClient = ApiClient();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => CitiesProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => PackagesProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => UsersProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => MembershipsProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => PaymentsProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => VisitsProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => StaffProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => AppointmentsProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => SeminarsProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => SupplementsProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => CategoriesProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => SuppliersProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => OrdersProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => ReviewsProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => FaqProvider(apiClient)),
      ],
      child: const StrongholdDesktopApp(),
    ),
  );
}

class StrongholdDesktopApp extends StatelessWidget {
  const StrongholdDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stronghold',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A5F)),
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) =>
            auth.isLoggedIn ? const MainLayout() : const LoginScreen(),
      ),
    );
  }
}
