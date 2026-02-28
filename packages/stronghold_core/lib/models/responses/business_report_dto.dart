import '../common/date_time_utils.dart';

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

class BusiestDayDTO {
  final DateTime date;
  final int visitCount;

  BusiestDayDTO({required this.date, required this.visitCount});

  factory BusiestDayDTO.fromJson(Map<String, dynamic> json) {
    return BusiestDayDTO(
      date: DateTimeUtils.parseApiDateTime(json['date'] as String),
      visitCount: (json['visitCount'] ?? 0) as int,
    );
  }
}

class PopularMembershipDTO {
  final int membershipPackageId;
  final String packageName;
  final int purchaseCount;

  PopularMembershipDTO({
    required this.membershipPackageId,
    required this.packageName,
    required this.purchaseCount,
  });

  factory PopularMembershipDTO.fromJson(Map<String, dynamic> json) {
    return PopularMembershipDTO(
      membershipPackageId: (json['membershipPackageId'] ?? 0) as int,
      packageName: (json['packageName'] ?? '') as String,
      purchaseCount: (json['purchaseCount'] ?? 0) as int,
    );
  }
}

class SlowestMovingDTO {
  final int supplementId;
  final String name;
  final int quantitySold;
  final int daysSinceLastSale;

  SlowestMovingDTO({
    required this.supplementId,
    required this.name,
    required this.quantitySold,
    required this.daysSinceLastSale,
  });

  factory SlowestMovingDTO.fromJson(Map<String, dynamic> json) {
    return SlowestMovingDTO(
      supplementId: (json['supplementId'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      quantitySold: (json['quantitySold'] ?? 0) as int,
      daysSinceLastSale: (json['daysSinceLastSale'] ?? 0) as int,
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

class DailySalesDTO {
  final DateTime date;
  final num revenue;
  final int orderCount;

  DailySalesDTO({
    required this.date,
    required this.revenue,
    required this.orderCount,
  });

  factory DailySalesDTO.fromJson(Map<String, dynamic> json) {
    return DailySalesDTO(
      date: DateTimeUtils.parseApiDateTime(json['date'] as String),
      revenue: (json['revenue'] ?? 0) as num,
      orderCount: (json['orderCount'] ?? 0) as int,
    );
  }
}

class RevenueBreakdownDTO {
  final num todayRevenue;
  final num thisWeekRevenue;
  final num thisMonthRevenue;
  final num averageOrderValue;
  final int todayOrderCount;
  final num monthOrderRevenue;

  RevenueBreakdownDTO({
    required this.todayRevenue,
    required this.thisWeekRevenue,
    required this.thisMonthRevenue,
    required this.averageOrderValue,
    required this.todayOrderCount,
    required this.monthOrderRevenue,
  });

  factory RevenueBreakdownDTO.fromJson(Map<String, dynamic> json) {
    return RevenueBreakdownDTO(
      todayRevenue: (json['todayRevenue'] ?? 0) as num,
      thisWeekRevenue: (json['thisWeekRevenue'] ?? 0) as num,
      thisMonthRevenue: (json['thisMonthRevenue'] ?? 0) as num,
      averageOrderValue: (json['averageOrderValue'] ?? 0) as num,
      todayOrderCount: (json['todayOrderCount'] ?? 0) as int,
      monthOrderRevenue: (json['monthOrderRevenue'] ?? 0) as num,
    );
  }
}

class ActivityFeedItemDTO {
  final String type;
  final String description;
  final DateTime timestamp;
  final String? userName;

  ActivityFeedItemDTO({
    required this.type,
    required this.description,
    required this.timestamp,
    this.userName,
  });

  factory ActivityFeedItemDTO.fromJson(Map<String, dynamic> json) {
    return ActivityFeedItemDTO(
      type: (json['type'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      timestamp: DateTimeUtils.parseApiDateTime(json['timestamp'] as String),
      userName: json['userName'] as String?,
    );
  }
}

class HeatmapCellDTO {
  final int day;  // 0..6 (Sunday=0 in .NET DayOfWeek)
  final int hour; // 0..23
  final int count;

  HeatmapCellDTO({required this.day, required this.hour, required this.count});

  factory HeatmapCellDTO.fromJson(Map<String, dynamic> json) {
    final rawDay = json['day'];
    int parsedDay;
    if (rawDay is int) {
      parsedDay = rawDay;
    } else if (rawDay is String) {
      const map = {
        'sunday': 0, 'monday': 1, 'tuesday': 2, 'wednesday': 3,
        'thursday': 4, 'friday': 5, 'saturday': 6,
      };
      parsedDay = map[rawDay.toLowerCase()] ?? int.tryParse(rawDay) ?? 0;
    } else {
      parsedDay = 0;
    }
    return HeatmapCellDTO(
      day: parsedDay,
      hour: (json['hour'] ?? 0) as int,
      count: (json['count'] ?? 0) as int,
    );
  }
}

class DailyVisitsDTO {
  final DateTime date;
  final int visitCount;

  DailyVisitsDTO({required this.date, required this.visitCount});

  factory DailyVisitsDTO.fromJson(Map<String, dynamic> json) {
    return DailyVisitsDTO(
      date: DateTimeUtils.parseApiDateTime(json['date'] as String),
      visitCount: (json['visitCount'] ?? 0) as int,
    );
  }
}

class MostActivePackageDTO {
  final String packageName;
  final int visitCount;

  MostActivePackageDTO({required this.packageName, required this.visitCount});

  factory MostActivePackageDTO.fromJson(Map<String, dynamic> json) {
    return MostActivePackageDTO(
      packageName: (json['packageName'] ?? '') as String,
      visitCount: (json['visitCount'] ?? 0) as int,
    );
  }
}

class GrowthRateDTO {
  final num growthPct;
  final int periodDays;

  GrowthRateDTO({required this.growthPct, required this.periodDays});

  factory GrowthRateDTO.fromJson(Map<String, dynamic> json) {
    return GrowthRateDTO(
      growthPct: (json['growthPct'] ?? 0) as num,
      periodDays: (json['periodDays'] ?? 30) as int,
    );
  }
}

class BusinessReportDTO {
  final int thisWeekVisits;
  final int lastWeekVisits;
  final num weekChangePct;
  final num thisMonthRevenue;
  final num lastMonthRevenue;
  final num monthChangePct;
  final int activeMemberships;
  final int expiringThisWeekCount;
  final int todayCheckIns;
  final int last30DaysCheckIns;
  final num avgDailyCheckIns;
  final List<WeekdayVisitsDTO> visitsByWeekday;
  final BestSellerDTO? bestsellerLast30Days;
  final SlowestMovingDTO? slowestMovingLast30Days;
  final PopularMembershipDTO? popularMembership;
  final int thisMonthVisits;
  final BusiestDayDTO? busiestDay;
  final List<DailySalesDTO> dailySales;
  final RevenueBreakdownDTO? revenueBreakdown;
  final List<HeatmapCellDTO> checkInHeatmap;
  final List<DailyVisitsDTO> dailyVisits;
  final MostActivePackageDTO? mostActivePackage;
  final GrowthRateDTO? growthRate;

  BusinessReportDTO({
    required this.thisWeekVisits,
    required this.lastWeekVisits,
    required this.weekChangePct,
    required this.thisMonthRevenue,
    required this.lastMonthRevenue,
    required this.monthChangePct,
    required this.activeMemberships,
    required this.expiringThisWeekCount,
    required this.todayCheckIns,
    required this.last30DaysCheckIns,
    required this.avgDailyCheckIns,
    required this.visitsByWeekday,
    required this.bestsellerLast30Days,
    this.slowestMovingLast30Days,
    this.popularMembership,
    required this.thisMonthVisits,
    this.busiestDay,
    required this.dailySales,
    this.revenueBreakdown,
    required this.checkInHeatmap,
    required this.dailyVisits,
    this.mostActivePackage,
    this.growthRate,
  });

  factory BusinessReportDTO.fromJson(Map<String, dynamic> json) {
    final visits = (json['visitsByWeekday'] as List<dynamic>?)
            ?.map((e) => WeekdayVisitsDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <WeekdayVisitsDTO>[];

    final bs = json['bestsellerLast30Days'];
    final sm = json['slowestMovingLast30Days'];
    final pm = json['popularMembership'];
    final bd = json['busiestDay'];

    final sales = (json['dailySales'] as List<dynamic>?)
            ?.map((e) => DailySalesDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <DailySalesDTO>[];

    final rb = json['revenueBreakdown'];

    final heatmap = (json['checkInHeatmap'] as List<dynamic>?)
            ?.map((e) => HeatmapCellDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <HeatmapCellDTO>[];

    final dv = (json['dailyVisits'] as List<dynamic>?)
            ?.map((e) => DailyVisitsDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <DailyVisitsDTO>[];

    final map = json['mostActivePackage'];
    final gr = json['growthRate'];

    return BusinessReportDTO(
      thisWeekVisits: (json['thisWeekVisits'] ?? 0) as int,
      lastWeekVisits: (json['lastWeekVisits'] ?? 0) as int,
      weekChangePct: (json['weekChangePct'] ?? 0) as num,
      thisMonthRevenue: (json['thisMonthRevenue'] ?? 0) as num,
      lastMonthRevenue: (json['lastMonthRevenue'] ?? 0) as num,
      monthChangePct: (json['monthChangePct'] ?? 0) as num,
      activeMemberships: (json['activeMemberships'] ?? 0) as int,
      expiringThisWeekCount: (json['expiringThisWeekCount'] ?? 0) as int,
      todayCheckIns: (json['todayCheckIns'] ?? 0) as int,
      last30DaysCheckIns: (json['last30DaysCheckIns'] ?? 0) as int,
      avgDailyCheckIns: (json['avgDailyCheckIns'] ?? 0) as num,
      visitsByWeekday: visits,
      bestsellerLast30Days:
          bs == null ? null : BestSellerDTO.fromJson(bs as Map<String, dynamic>),
      slowestMovingLast30Days:
          sm == null ? null : SlowestMovingDTO.fromJson(sm as Map<String, dynamic>),
      popularMembership:
          pm == null ? null : PopularMembershipDTO.fromJson(pm as Map<String, dynamic>),
      thisMonthVisits: (json['thisMonthVisits'] ?? 0) as int,
      busiestDay:
          bd == null ? null : BusiestDayDTO.fromJson(bd as Map<String, dynamic>),
      dailySales: sales,
      revenueBreakdown:
          rb == null ? null : RevenueBreakdownDTO.fromJson(rb as Map<String, dynamic>),
      checkInHeatmap: heatmap,
      dailyVisits: dv,
      mostActivePackage: map == null
          ? null
          : MostActivePackageDTO.fromJson(map as Map<String, dynamic>),
      growthRate: gr == null
          ? null
          : GrowthRateDTO.fromJson(gr as Map<String, dynamic>),
    );
  }
}

// INVENTORY REPORT DTOs

/// Summary for inventory header (separate from paginated products)
class InventorySummaryDTO {
  final int totalProducts;
  final int slowMovingCount;
  final int daysAnalyzed;

  InventorySummaryDTO({
    required this.totalProducts,
    required this.slowMovingCount,
    required this.daysAnalyzed,
  });

  factory InventorySummaryDTO.fromJson(Map<String, dynamic> json) {
    return InventorySummaryDTO(
      totalProducts: (json['totalProducts'] ?? 0) as int,
      slowMovingCount: (json['slowMovingCount'] ?? 0) as int,
      daysAnalyzed: (json['daysAnalyzed'] ?? 30) as int,
    );
  }
}

class SlowMovingProductDTO {
  final int supplementId;
  final String name;
  final String categoryName;
  final num price;
  final int quantitySold;
  final int daysSinceLastSale;

  SlowMovingProductDTO({
    required this.supplementId,
    required this.name,
    required this.categoryName,
    required this.price,
    required this.quantitySold,
    required this.daysSinceLastSale,
  });

  factory SlowMovingProductDTO.fromJson(Map<String, dynamic> json) {
    return SlowMovingProductDTO(
      supplementId: (json['supplementId'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      categoryName: (json['categoryName'] ?? '') as String,
      price: (json['price'] ?? 0) as num,
      quantitySold: (json['quantitySold'] ?? 0) as int,
      daysSinceLastSale: (json['daysSinceLastSale'] ?? 0) as int,
    );
  }
}

class InventoryReportDTO {
  final List<SlowMovingProductDTO> slowMovingProducts;
  final int totalProducts;
  final int slowMovingCount;
  final int daysAnalyzed;

  InventoryReportDTO({
    required this.slowMovingProducts,
    required this.totalProducts,
    required this.slowMovingCount,
    required this.daysAnalyzed,
  });

  factory InventoryReportDTO.fromJson(Map<String, dynamic> json) {
    final products = (json['slowMovingProducts'] as List<dynamic>?)
            ?.map((e) => SlowMovingProductDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <SlowMovingProductDTO>[];

    return InventoryReportDTO(
      slowMovingProducts: products,
      totalProducts: (json['totalProducts'] ?? 0) as int,
      slowMovingCount: (json['slowMovingCount'] ?? 0) as int,
      daysAnalyzed: (json['daysAnalyzed'] ?? 30) as int,
    );
  }
}

// MEMBERSHIP POPULARITY REPORT DTOs

class MembershipPlanStatsDTO {
  final int membershipPackageId;
  final String packageName;
  final num packagePrice;
  final int activeSubscriptions;
  final int newSubscriptionsLast30Days;
  final num revenueLast90Days;
  final num popularityPercentage;

  MembershipPlanStatsDTO({
    required this.membershipPackageId,
    required this.packageName,
    required this.packagePrice,
    required this.activeSubscriptions,
    required this.newSubscriptionsLast30Days,
    required this.revenueLast90Days,
    required this.popularityPercentage,
  });

  factory MembershipPlanStatsDTO.fromJson(Map<String, dynamic> json) {
    return MembershipPlanStatsDTO(
      membershipPackageId: (json['membershipPackageId'] ?? 0) as int,
      packageName: (json['packageName'] ?? '') as String,
      packagePrice: (json['packagePrice'] ?? 0) as num,
      activeSubscriptions: (json['activeSubscriptions'] ?? 0) as int,
      newSubscriptionsLast30Days: (json['newSubscriptionsLast30Days'] ?? 0) as int,
      revenueLast90Days: (json['revenueLast90Days'] ?? 0) as num,
      popularityPercentage: (json['popularityPercentage'] ?? 0) as num,
    );
  }
}

class MembershipPopularityReportDTO {
  final List<MembershipPlanStatsDTO> planStats;
  final int totalActiveMemberships;
  final num totalRevenueLast90Days;

  MembershipPopularityReportDTO({
    required this.planStats,
    required this.totalActiveMemberships,
    required this.totalRevenueLast90Days,
  });

  factory MembershipPopularityReportDTO.fromJson(Map<String, dynamic> json) {
    final stats = (json['planStats'] as List<dynamic>?)
            ?.map((e) => MembershipPlanStatsDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <MembershipPlanStatsDTO>[];

    return MembershipPopularityReportDTO(
      planStats: stats,
      totalActiveMemberships: (json['totalActiveMemberships'] ?? 0) as int,
      totalRevenueLast90Days: (json['totalRevenueLast90Days'] ?? 0) as num,
    );
  }
}
