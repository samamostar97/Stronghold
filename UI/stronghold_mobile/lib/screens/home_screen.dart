import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/app_theme.dart';
import 'leaderboard_screen.dart';
import 'notifications_screen.dart';

/// Pocetni ekran - pregled informacija clana, XP napredak i notifikacije.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ProfileProvider>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final unread = context.watch<NotificationsProvider>().unreadCount;
    final progress = profileProvider.progress;
    final weekdayLabels = const ['Pon', 'Uto', 'Sri', 'Čet', 'Pet', 'Sub', 'Ned'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stronghold'),
        actions: [
          IconButton(
            tooltip: 'Rang lista',
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Notifikacije',
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Odjava',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: profileProvider.loading && progress == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => profileProvider.load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Zdravo, ${profileProvider.profile?.firstName ?? ''}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  if (progress != null) ...[
                    // hero kartica napretka - puna navy podloga, prsten oko nivoa
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.navy,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 76,
                            height: 76,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CircularProgressIndicator(
                                  value: progress.levelProgressPercent / 100,
                                  strokeWidth: 5,
                                  strokeCap: StrokeCap.round,
                                  color: Colors.white,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.18),
                                ),
                                Center(
                                  child: Text(
                                    '${progress.level}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NIVO ${progress.level}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${progress.xp} XP',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${progress.levelProgressPercent}% do sljedećeg nivoa',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            context,
                            Icons.fitness_center,
                            '${progress.totalVisits}',
                            'ukupno posjeta',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            context,
                            Icons.timer_outlined,
                            '${(progress.monthlyMinutes / 60).toStringAsFixed(1)}h',
                            'zadnjih 30 dana',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Posjete po danima u sedmici',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 120,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  for (var day = 0; day < 7; day++)
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 4),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              // tinted track + stub sa zaobljenim vrhom,
                                              // najjaci dan punom bojom
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppTheme.navyTint,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                alignment: Alignment.bottomCenter,
                                                child: FractionallySizedBox(
                                                  heightFactor: _barHeight(
                                                      progress.visitsByWeekday, day),
                                                  child: Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: _isTopDay(
                                                              progress.visitsByWeekday,
                                                              day)
                                                          ? AppTheme.navy
                                                          : AppTheme.navy
                                                              .withValues(alpha: 0.45),
                                                      borderRadius:
                                                          BorderRadius.circular(6),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              weekdayLabels[day],
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: _isTopDay(
                                                        progress.visitsByWeekday, day)
                                                    ? FontWeight.w800
                                                    : FontWeight.w600,
                                                color: _isTopDay(
                                                        progress.visitsByWeekday, day)
                                                    ? AppTheme.navy
                                                    : AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  double _barHeight(List<int> visitsByWeekday, int day) {
    final max = visitsByWeekday.fold(0, (a, b) => a > b ? a : b);
    if (max == 0) return 0.02;
    final factor = visitsByWeekday[day] / max;
    return factor < 0.02 ? 0.02 : factor;
  }

  bool _isTopDay(List<int> visitsByWeekday, int day) {
    final max = visitsByWeekday.fold(0, (a, b) => a > b ? a : b);
    return max > 0 && visitsByWeekday[day] == max;
  }

  Widget _statCard(BuildContext context, IconData icon, String value, String label) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.navyTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: AppTheme.navy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
