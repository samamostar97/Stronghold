import '../api/api_client.dart';
import '../models/responses/leaderboard_entry_response.dart';

/// Leaderboard service for fetching leaderboard data
class LeaderboardService {
  final ApiClient _client;
  static const String _path = '/api/profile/leaderboard/full';

  LeaderboardService(this._client);

  /// Get the leaderboard
  Future<List<LeaderboardEntryResponse>> getLeaderboard() async {
    return _client.get<List<LeaderboardEntryResponse>>(
      _path,
      parser: (json) {
        final list = json as List<dynamic>;
        return list
            .map((item) => LeaderboardEntryResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
