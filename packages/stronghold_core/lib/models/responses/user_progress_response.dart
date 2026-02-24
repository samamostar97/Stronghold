/// Weekly visit entry in user progress
class WeeklyVisitResponse {
  final DateTime date;
  final int minutes;
  final String dayName;

  const WeeklyVisitResponse({
    required this.date,
    required this.minutes,
    required this.dayName,
  });

  factory WeeklyVisitResponse.fromJson(Map<String, dynamic> json) {
    return WeeklyVisitResponse(
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

/// User progress response from profile endpoint
class UserProgressResponse {
  final int userId;
  final String fullName;
  final int level;
  final int currentXP;
  final int xpForNextLevel;
  final int xpProgress;
  final double progressPercentage;
  final int totalGymMinutesThisWeek;
  final List<WeeklyVisitResponse> weeklyVisits;

  const UserProgressResponse({
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

  factory UserProgressResponse.fromJson(Map<String, dynamic> json) {
    return UserProgressResponse(
      userId: json['userId'] as int,
      fullName: json['fullName'] as String,
      level: json['level'] as int,
      currentXP: json['currentXP'] as int,
      xpForNextLevel: json['xpForNextLevel'] as int,
      xpProgress: json['xpProgress'] as int,
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      totalGymMinutesThisWeek: json['totalGymMinutesThisWeek'] as int,
      weeklyVisits: (json['weeklyVisits'] as List<dynamic>)
          .map((v) => WeeklyVisitResponse.fromJson(v as Map<String, dynamic>))
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
