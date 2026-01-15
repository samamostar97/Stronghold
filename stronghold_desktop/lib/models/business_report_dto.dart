class BestSellerDTO {
  final int supplementId;
  final String name;
  final int quantitySold;

  BestSellerDTO({
    required this.supplementId,
    required this.name,
    required this.quantitySold,
  });

  factory BestSellerDTO.fromJson(Map<String, dynamic> json) {
    return BestSellerDTO(
      supplementId: (json['supplementId'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      quantitySold: (json['quantitySold'] ?? 0) as int,
    );
  }
}

class WeekdayVisitsDTO {
  /// Backend šalje DayOfWeek kao int (0..6) ili string, zavisi od JSON options.
  /// Ovo je "safe" parsing za oba.
  final int day; // 0..6 (Sunday=0 in .NET)
  final int count;

  WeekdayVisitsDTO({required this.day, required this.count});

  factory WeekdayVisitsDTO.fromJson(Map<String, dynamic> json) {
    final rawDay = json['day'];
    int parsedDay;

    if (rawDay is int) {
      parsedDay = rawDay;
    } else if (rawDay is String) {
      // "Monday", "Tuesday"... ili "1", itd.
      final s = rawDay.toLowerCase();
      const map = {
        'sunday': 0,
        'monday': 1,
        'tuesday': 2,
        'wednesday': 3,
        'thursday': 4,
        'friday': 5,
        'saturday': 6,
      };
      parsedDay = map[s] ?? int.tryParse(rawDay) ?? 0;
    } else {
      parsedDay = 0;
    }

    return WeekdayVisitsDTO(
      day: parsedDay,
      count: (json['count'] ?? 0) as int,
    );
  }
}

class BusinessReportDTO {
  final int thisWeekVisits;
  final int lastWeekVisits;
  final num weekChangePct; // decimal u backendu
  final num thisMonthRevenue;
  final num lastMonthRevenue;
  final num monthChangePct;
  final int activeMemberships;
  final List<WeekdayVisitsDTO> visitsByWeekday;
  final BestSellerDTO? bestsellerLast30Days;

  BusinessReportDTO({
    required this.thisWeekVisits,
    required this.lastWeekVisits,
    required this.weekChangePct,
    required this.thisMonthRevenue,
    required this.lastMonthRevenue,
    required this.monthChangePct,
    required this.activeMemberships,
    required this.visitsByWeekday,
    required this.bestsellerLast30Days,
  });

  factory BusinessReportDTO.fromJson(Map<String, dynamic> json) {
    final visits = (json['visitsByWeekday'] as List<dynamic>?)
            ?.map((e) => WeekdayVisitsDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <WeekdayVisitsDTO>[];

    final bs = json['bestsellerLast30Days'];
    return BusinessReportDTO(
      thisWeekVisits: (json['thisWeekVisits'] ?? 0) as int,
      lastWeekVisits: (json['lastWeekVisits'] ?? 0) as int,
      weekChangePct: (json['weekChangePct'] ?? 0) as num,
      thisMonthRevenue: (json['thisMonthRevenue'] ?? 0) as num,
      lastMonthRevenue: (json['lastMonthRevenue'] ?? 0) as num,
      monthChangePct: (json['monthChangePct'] ?? 0) as num,
      activeMemberships: (json['activeMemberships'] ?? 0) as int,
      visitsByWeekday: visits,
      bestsellerLast30Days:
          bs == null ? null : BestSellerDTO.fromJson(bs as Map<String, dynamic>),
    );
  }
}
