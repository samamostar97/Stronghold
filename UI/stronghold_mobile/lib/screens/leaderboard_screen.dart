import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/leaderboard_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<LeaderboardProvider>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();
    final myUserId = context.read<AuthProvider>().member?.userId;

    return Scaffold(
      appBar: AppBar(title: const Text('Rang lista')),
      body: provider.loading && provider.entries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.load(),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: provider.entries.length,
                itemBuilder: (context, index) {
                  final entry = provider.entries[index];
                  final isMe = entry.userId == myUserId;
                  final medal = switch (entry.rank) {
                    1 => '🥇',
                    2 => '🥈',
                    3 => '🥉',
                    _ => null,
                  };
                  return Card(
                    color: isMe
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    child: ListTile(
                      leading: medal != null
                          ? Text(medal, style: const TextStyle(fontSize: 28))
                          : CircleAvatar(
                              radius: 16,
                              child: Text('${entry.rank}'),
                            ),
                      title: Text(
                        isMe ? '${entry.fullName} (vi)' : entry.fullName,
                        style: TextStyle(
                          fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        '${entry.visitCount} posjeta - ${entry.totalHours}h treninga',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.xp} XP',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Nivo ${entry.level}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
