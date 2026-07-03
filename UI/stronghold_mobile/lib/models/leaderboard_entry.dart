class LeaderboardEntry {
  final int rank;
  final int userId;
  final String fullName;
  final String username;
  final int xp;
  final int level;
  final int visitCount;
  final int totalHours;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.fullName,
    required this.username,
    required this.xp,
    required this.level,
    required this.visitCount,
    required this.totalHours,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        rank: json['rank'] as int,
        userId: json['userId'] as int,
        fullName: json['fullName'] as String,
        username: json['username'] as String,
        xp: json['xp'] as int,
        level: json['level'] as int,
        visitCount: json['visitCount'] as int,
        totalHours: json['totalHours'] as int,
      );
}
