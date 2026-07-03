import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/profile_provider.dart';
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
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  child: Text(
                                    '${progress.level}',
                                    style: const TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Nivo ${progress.level}',
                                          style:
                                              Theme.of(context).textTheme.titleMedium),
                                      Text('${progress.xp} XP'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress.levelProgressPercent / 100,
                                minHeight: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('${progress.levelProgressPercent}% do sljedećeg nivoa'),
                          ],
                        ),
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
                                              child: Align(
                                                alignment: Alignment.bottomCenter,
                                                child: FractionallySizedBox(
                                                  heightFactor: _barHeight(
                                                      progress.visitsByWeekday, day),
                                                  child: Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      borderRadius:
                                                          BorderRadius.circular(4),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(weekdayLabels[day],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall),
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

  Widget _statCard(BuildContext context, IconData icon, String value, String label) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
