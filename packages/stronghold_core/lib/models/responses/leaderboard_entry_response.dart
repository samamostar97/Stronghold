/// Leaderboard entry response from backend
class LeaderboardEntryResponse {
  final int rank;
  final int userId;
  final String fullName;
  final String? profileImageUrl;
  final int level;
  final int currentXP;

  const LeaderboardEntryResponse({
    required this.rank,
    required this.userId,
    required this.fullName,
    this.profileImageUrl,
    required this.level,
    required this.currentXP,
  });

  factory LeaderboardEntryResponse.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryResponse(
      rank: json['rank'] as int,
      userId: json['userId'] as int,
      fullName: json['fullName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      level: json['level'] as int,
      currentXP: json['currentXP'] as int,
    );
  }
}
