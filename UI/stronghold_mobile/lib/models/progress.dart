/// XP i analitika napretka clana.
class Progress {
  final int xp;
  final int level;
  final int levelProgressPercent;
  final int totalVisits;
  final int monthlyMinutes;
  final List<int> visitsByWeekday;
  final List<WeeklyVisits> weeklyVisits;

  Progress({
    required this.xp,
    required this.level,
    required this.levelProgressPercent,
    required this.totalVisits,
    required this.monthlyMinutes,
    required this.visitsByWeekday,
    required this.weeklyVisits,
  });

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
        xp: json['xp'] as int,
        level: json['level'] as int,
        levelProgressPercent: json['levelProgressPercent'] as int,
        totalVisits: json['totalVisits'] as int,
        monthlyMinutes: json['monthlyMinutes'] as int,
        visitsByWeekday: (json['visitsByWeekday'] as List).cast<int>(),
        weeklyVisits: (json['weeklyVisits'] as List)
            .map((week) => WeeklyVisits.fromJson(week as Map<String, dynamic>))
            .toList(),
      );
}

class WeeklyVisits {
  final DateTime weekStart;
  final int count;

  WeeklyVisits({required this.weekStart, required this.count});

  factory WeeklyVisits.fromJson(Map<String, dynamic> json) => WeeklyVisits(
        weekStart: DateTime.parse(json['weekStart'] as String),
        count: json['count'] as int,
      );
}
