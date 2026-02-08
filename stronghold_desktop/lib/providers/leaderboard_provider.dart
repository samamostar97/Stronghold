import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';

/// Leaderboard service provider
final leaderboardServiceProvider = Provider<LeaderboardService>((ref) {
  return LeaderboardService(ref.watch(apiClientProvider));
});

/// Leaderboard data provider
final leaderboardProvider = FutureProvider<List<LeaderboardEntryResponse>>((ref) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getLeaderboard();
});
