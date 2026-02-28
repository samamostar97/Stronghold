import 'business_report_dto.dart';

class DashboardOverviewDTO {
  final int activeMemberships;
  final int expiringThisWeekCount;
  final int todayCheckIns;
  final List<DailyVisitsDTO> dailyVisits;

  DashboardOverviewDTO({
    required this.activeMemberships,
    required this.expiringThisWeekCount,
    required this.todayCheckIns,
    required this.dailyVisits,
  });

  factory DashboardOverviewDTO.fromJson(Map<String, dynamic> json) {
    final visits =
        (json['dailyVisits'] as List<dynamic>?)
            ?.map((e) => DailyVisitsDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <DailyVisitsDTO>[];

    return DashboardOverviewDTO(
      activeMemberships: (json['activeMemberships'] ?? 0) as int,
      expiringThisWeekCount: (json['expiringThisWeekCount'] ?? 0) as int,
      todayCheckIns: (json['todayCheckIns'] ?? 0) as int,
      dailyVisits: visits,
    );
  }
}
