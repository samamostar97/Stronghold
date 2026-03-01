import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/login_success_screen.dart';
import '../screens/navigation_shell.dart';
import '../screens/home_screen.dart';
import '../screens/supplement_shop_screen.dart';
import '../screens/profile_settings_screen.dart';
import '../screens/supplement_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/order_history_screen.dart';
import '../screens/address_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/appointment_screen.dart';
import '../screens/book_appointment_screen.dart';
import '../screens/trainer_list_screen.dart';
import '../screens/nutritionist_list_screen.dart';
import '../screens/seminar_screen.dart';
import '../screens/faq_screen.dart';
import '../screens/review_history_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/user_progress_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      // ── Auth (no bottom nav) ──
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/login-success',
        builder: (_, __) => const LoginSuccessScreen(),
      ),

      // ── Main app (with bottom nav shell) ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return NavigationShellWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/appointments',
                builder: (_, __) => const AppointmentScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/shop',
                builder: (_, __) => const SupplementShopScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfileSettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Detail screens (pushed on top, no bottom nav) ──
      GoRoute(
        path: '/shop/detail',
        builder: (_, state) => SupplementDetailScreen(
          supplement: state.extra as SupplementResponse,
        ),
      ),
      GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
      GoRoute(path: '/orders', builder: (_, __) => const OrderHistoryScreen()),
      GoRoute(
        path: '/reviews',
        builder: (_, __) => const ReviewHistoryScreen(),
      ),
      GoRoute(path: '/address', builder: (_, __) => const AddressScreen()),
      GoRoute(
        path: '/change-password',
        builder: (_, __) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/book-appointment',
        builder: (_, state) {
          final args = state.extra as BookAppointmentArgs;
          return BookAppointmentScreen(
            staffId: args.staffId,
            staffName: args.staffName,
            staffType: args.staffType,
          );
        },
      ),
      GoRoute(path: '/trainers', builder: (_, __) => const TrainerListScreen()),
      GoRoute(
        path: '/nutritionists',
        builder: (_, __) => const NutritionistListScreen(),
      ),
      GoRoute(path: '/seminars', builder: (_, __) => const SeminarScreen()),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationScreen(),
      ),
      GoRoute(path: '/faq', builder: (_, __) => const FaqScreen()),
      GoRoute(
        path: '/leaderboard',
        builder: (_, __) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/progress',
        builder: (_, __) => const UserProgressScreen(),
      ),
    ],
  );
});
