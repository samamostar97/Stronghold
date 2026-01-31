class UserProgress {
  final int userId;
  final String fullName;
  final int level;
  final int currentXP;
  final int xpForNextLevel;
  final int xpProgress;
  final double progressPercentage;
  final int totalGymMinutesThisWeek;
  final List<WeeklyVisit> weeklyVisits;

  UserProgress({
    required this.userId,
    required this.fullName,
    required this.level,
    required this.currentXP,
    required this.xpForNextLevel,
    required this.xpProgress,
    required this.progressPercentage,
    required this.totalGymMinutesThisWeek,
    required this.weeklyVisits,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'] as int,
      fullName: json['fullName'] as String,
      level: json['level'] as int,
      currentXP: json['currentXP'] as int,
      xpForNextLevel: json['xpForNextLevel'] as int,
      xpProgress: json['xpProgress'] as int,
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      totalGymMinutesThisWeek: json['totalGymMinutesThisWeek'] as int,
      weeklyVisits: (json['weeklyVisits'] as List<dynamic>)
          .map((v) => WeeklyVisit.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  String get formattedWeeklyTime {
    final hours = totalGymMinutesThisWeek ~/ 60;
    final minutes = totalGymMinutesThisWeek % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }
}

class WeeklyVisit {
  final DateTime date;
  final int minutes;
  final String dayName;

  WeeklyVisit({
    required this.date,
    required this.minutes,
    required this.dayName,
  });

  factory WeeklyVisit.fromJson(Map<String, dynamic> json) {
    return WeeklyVisit(
      date: DateTime.parse(json['date'] as String),
      minutes: json['minutes'] as int,
      dayName: json['dayName'] as String,
    );
  }

  String get formattedTime {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }
}

class LeaderboardEntry {
  final int rank;
  final int userId;
  final String fullName;
  final String? profileImageUrl;
  final int level;
  final int currentXP;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.fullName,
    this.profileImageUrl,
    required this.level,
    required this.currentXP,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      userId: json['userId'] as int,
      fullName: json['fullName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      level: json['level'] as int,
      currentXP: json['currentXP'] as int,
    );
  }
}
