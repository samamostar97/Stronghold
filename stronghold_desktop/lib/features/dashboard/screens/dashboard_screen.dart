import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../gym/widgets/check_in_modal.dart';
import '../../memberships/widgets/assign_membership_modal.dart';
import '../../products/widgets/product_form_modal.dart';
import '../../users/widgets/user_form_modal.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/activity_feed.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final activityAsync = ref.watch(dashboardActivityProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Stats
          Text('Pregled', style: AppTextStyles.h2),
          const SizedBox(height: 20),
          statsAsync.when(
            loading: () => const _StatsLoading(),
            error: (e, _) => _StatsError(onRetry: () => ref.invalidate(dashboardStatsProvider)),
            data: (stats) => _StatsGrid(
              stats: stats,
              wide: screenWidth > 1200,
              onNavigate: (route) => context.go(route),
            ),
          ),

          const SizedBox(height: 36),

          // Section: Quick Actions
          Text('Brze akcije', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          _QuickActionsGrid(
            wide: screenWidth > 1200,
          ),

          const SizedBox(height: 36),

          // Section: Activity Feed
          Text('Posljednje aktivnosti', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.sidebar,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: activityAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Greska pri ucitavanju aktivnosti',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(dashboardActivityProvider),
                        child: Text(
                          'Pokusaj ponovo',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              data: (activities) => ActivityFeed(activities: activities),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool wide;
  final ValueChanged<String> onNavigate;

  const _StatsGrid({
    required this.stats,
    required this.wide,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      StatCard(
        icon: Icons.fitness_center_outlined,
        label: 'Trenutno u teretani',
        value: '${stats['activeGymVisits'] ?? 0}',
        onTap: () => onNavigate('/gym'),
      ),
      StatCard(
        icon: Icons.card_membership_outlined,
        label: 'Aktivne clanarine',
        value: '${stats['activeMemberships'] ?? 0}',
        onTap: () => onNavigate('/memberships'),
      ),
      StatCard(
        icon: Icons.shopping_bag_outlined,
        label: 'Pending narudzbe',
        value: '${stats['pendingOrders'] ?? 0}',
        onTap: () => onNavigate('/orders'),
      ),
      StatCard(
        icon: Icons.calendar_today_outlined,
        label: 'Pending termini',
        value: '${stats['pendingAppointments'] ?? 0}',
        onTap: () => onNavigate('/staff/appointments'),
      ),
    ];

    if (wide) {
      return Row(
        children: cards
            .map((card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: card,
                  ),
                ))
            .toList(),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.8,
      children: cards,
    );
  }
}

class _StatsLoading extends StatelessWidget {
  const _StatsLoading();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        4,
        (_) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Container(
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.sidebar,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  final bool wide;

  const _QuickActionsGrid({required this.wide});

  @override
  Widget build(BuildContext context) {
    final cards = [
      QuickActionCard(
        icon: Icons.login_rounded,
        label: 'Check-in korisnika',
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => const CheckInModal(),
          );
        },
      ),
      QuickActionCard(
        icon: Icons.person_add_outlined,
        label: 'Dodaj korisnika',
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => const UserFormModal(),
          );
        },
      ),
      QuickActionCard(
        icon: Icons.card_membership_outlined,
        label: 'Dodaj clanarinu',
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => const AssignMembershipModal(),
          );
        },
      ),
      QuickActionCard(
        icon: Icons.add_box_outlined,
        label: 'Dodaj proizvod',
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => const ProductFormModal(),
          );
        },
      ),
    ];

    if (wide) {
      return Row(
        children: cards
            .map((card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: card,
                  ),
                ))
            .toList(),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.8,
      children: cards,
    );
  }
}

class _StatsError extends StatelessWidget {
  final VoidCallback onRetry;

  const _StatsError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.sidebar,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Greska pri ucitavanju statistika',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Pokusaj ponovo',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
