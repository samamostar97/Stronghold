import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reports_provider.dart';
import '../widgets/stretch_scroll.dart';

/// Rangiranje clanova po XP-u i broju posjeta (top lista - bez parametra pretrage).
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
      (_) => context.read<ReportsProvider>().loadLeaderboard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<ReportsProvider>().leaderboard;

    if (entries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: SingleChildScrollView(
        child: StretchScroll(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Rang')),
              DataColumn(label: Text('Član')),
              DataColumn(label: Text('XP')),
              DataColumn(label: Text('Nivo')),
              DataColumn(label: Text('Posjete')),
              DataColumn(label: Text('Sati treninga')),
            ],
            rows: [
              for (final entry in entries)
                DataRow(cells: [
                  DataCell(Text(switch (entry.rank) {
                    1 => '🥇',
                    2 => '🥈',
                    3 => '🥉',
                    _ => '${entry.rank}.',
                  })),
                  DataCell(Text('${entry.fullName} (${entry.username})')),
                  DataCell(Text('${entry.xp}')),
                  DataCell(Text('${entry.level}')),
                  DataCell(Text('${entry.visitCount}')),
                  DataCell(Text('${entry.totalHours}h')),
                ]),
            ],
          ),
        ),
      ),
    );
  }
}
