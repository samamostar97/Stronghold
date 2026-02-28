import 'package:stronghold_core/stronghold_core.dart';

/// User profile service (progress, leaderboard, membership history, picture)
class ProfileService {
  final ApiClient _client;

  ProfileService(this._client);

  /// Get current user's progress data
  Future<UserProgressResponse> getProgress() async {
    return _client.get<UserProgressResponse>(
      '/api/profile/progress',
      parser: (json) =>
          UserProgressResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Get leaderboard entries
  Future<List<LeaderboardEntryResponse>> getLeaderboard() async {
    return _client.get<List<LeaderboardEntryResponse>>(
      '/api/profile/leaderboard',
      parser: (json) => (json as List<dynamic>)
          .map((j) =>
              LeaderboardEntryResponse.fromJson(j as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get current user's membership payment history
  Future<List<MembershipPaymentResponse>> getMembershipHistory() async {
    return _client.get<List<MembershipPaymentResponse>>(
      '/api/profile/membership-history',
      parser: (json) => (json as List<dynamic>)
          .map((j) =>
              MembershipPaymentResponse.fromJson(j as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Upload profile picture, returns the new image URL
  Future<String> uploadPicture(String filePath) async {
    return _client.uploadFile<String>(
      '/api/profile/picture',
      filePath,
      'file',
      parser: (json) => (json as Map<String, dynamic>)['url'] as String,
    );
  }

  /// Delete profile picture
  Future<void> deletePicture() async {
    await _client.delete('/api/profile/picture');
  }
}
