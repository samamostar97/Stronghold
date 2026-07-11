/// Modeli dashboarda i biznis reporta.
class Dashboard {
  final int activeMembers;
  final int visitsToday;
  final int currentlyInGym;
  final double revenueThisMonth;
  final int newOrdersCount;
  final List<DashboardOrder> latestOrders;
  final List<LowStockSupplement> lowStockSupplements;
  final int lowStockCount;
  final List<ExpiringMembership> expiringMemberships;
  final int expiringMembershipsCount;
  final List<DashboardOrder> stuckOrders;
  final int stuckOrdersCount;

  Dashboard({
    required this.activeMembers,
    required this.visitsToday,
    required this.currentlyInGym,
    required this.revenueThisMonth,
    required this.newOrdersCount,
    required this.latestOrders,
    required this.lowStockSupplements,
    required this.lowStockCount,
    required this.expiringMemberships,
    required this.expiringMembershipsCount,
    required this.stuckOrders,
    required this.stuckOrdersCount,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) => Dashboard(
        activeMembers: json['activeMembers'] as int,
        visitsToday: json['visitsToday'] as int,
        currentlyInGym: json['currentlyInGym'] as int,
        revenueThisMonth: (json['revenueThisMonth'] as num).toDouble(),
        newOrdersCount: json['newOrdersCount'] as int,
        latestOrders: (json['latestOrders'] as List)
            .map((item) => DashboardOrder.fromJson(item as Map<String, dynamic>))
            .toList(),
        lowStockSupplements: (json['lowStockSupplements'] as List)
            .map((item) =>
                LowStockSupplement.fromJson(item as Map<String, dynamic>))
            .toList(),
        lowStockCount: json['lowStockCount'] as int,
        expiringMemberships: (json['expiringMemberships'] as List)
            .map((item) =>
                ExpiringMembership.fromJson(item as Map<String, dynamic>))
            .toList(),
        expiringMembershipsCount: json['expiringMembershipsCount'] as int,
        stuckOrders: (json['stuckOrders'] as List)
            .map((item) => DashboardOrder.fromJson(item as Map<String, dynamic>))
            .toList(),
        stuckOrdersCount: json['stuckOrdersCount'] as int,
      );
}

class DashboardOrder {
  final int id;
  final String userFullName;
  final DateTime createdAt;
  final double totalAmount;
  final String status;
  final bool isNew;

  DashboardOrder({
    required this.id,
    required this.userFullName,
    required this.createdAt,
    required this.totalAmount,
    required this.status,
    required this.isNew,
  });

  factory DashboardOrder.fromJson(Map<String, dynamic> json) => DashboardOrder(
        id: json['id'] as int,
        userFullName: json['userFullName'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        status: json['status'] as String,
        isNew: json['isNew'] as bool,
      );
}

class LowStockSupplement {
  final String name;
  final int stockQuantity;

  LowStockSupplement({required this.name, required this.stockQuantity});

  factory LowStockSupplement.fromJson(Map<String, dynamic> json) =>
      LowStockSupplement(
        name: json['name'] as String,
        stockQuantity: json['stockQuantity'] as int,
      );
}

class ExpiringMembership {
  final String userFullName;
  final String packageName;
  final DateTime endDate;

  ExpiringMembership({
    required this.userFullName,
    required this.packageName,
    required this.endDate,
  });

  factory ExpiringMembership.fromJson(Map<String, dynamic> json) =>
      ExpiringMembership(
        userFullName: json['userFullName'] as String,
        packageName: json['packageName'] as String,
        endDate: DateTime.parse(json['endDate'] as String),
      );
}

class RevenueReport {
  final double revenueThisMonth;
  final double revenueLast6Months;
  final double avgOrderValue6M;
  final double orderCancellationRate6M;
  final List<MonthlyRevenue> monthlyRevenue;
  final List<TopProduct> topProducts;
  final List<CategoryRevenue> revenueByCategory;

  RevenueReport({
    required this.revenueThisMonth,
    required this.revenueLast6Months,
    required this.avgOrderValue6M,
    required this.orderCancellationRate6M,
    required this.monthlyRevenue,
    required this.topProducts,
    required this.revenueByCategory,
  });

  factory RevenueReport.fromJson(Map<String, dynamic> json) => RevenueReport(
        revenueThisMonth: (json['revenueThisMonth'] as num).toDouble(),
        revenueLast6Months: (json['revenueLast6Months'] as num).toDouble(),
        avgOrderValue6M: (json['avgOrderValue6M'] as num).toDouble(),
        orderCancellationRate6M:
            (json['orderCancellationRate6M'] as num).toDouble(),
        monthlyRevenue: (json['monthlyRevenue'] as List)
            .map((item) => MonthlyRevenue.fromJson(item as Map<String, dynamic>))
            .toList(),
        topProducts: (json['topProducts'] as List)
            .map((item) => TopProduct.fromJson(item as Map<String, dynamic>))
            .toList(),
        revenueByCategory: (json['revenueByCategory'] as List)
            .map((item) =>
                CategoryRevenue.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class CategoryRevenue {
  final String categoryName;
  final int quantitySold;
  final double revenue;
  final double revenueShare;

  CategoryRevenue({
    required this.categoryName,
    required this.quantitySold,
    required this.revenue,
    required this.revenueShare,
  });

  factory CategoryRevenue.fromJson(Map<String, dynamic> json) =>
      CategoryRevenue(
        categoryName: json['categoryName'] as String,
        quantitySold: json['quantitySold'] as int,
        revenue: (json['revenue'] as num).toDouble(),
        revenueShare: (json['revenueShare'] as num).toDouble(),
      );
}

class MonthlyRevenue {
  final int year;
  final int month;
  final double membershipRevenue;
  final double orderRevenue;

  MonthlyRevenue({
    required this.year,
    required this.month,
    required this.membershipRevenue,
    required this.orderRevenue,
  });

  double get total => membershipRevenue + orderRevenue;

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) => MonthlyRevenue(
        year: json['year'] as int,
        month: json['month'] as int,
        membershipRevenue: (json['membershipRevenue'] as num).toDouble(),
        orderRevenue: (json['orderRevenue'] as num).toDouble(),
      );
}

class TopProduct {
  final String name;
  final String categoryName;
  final int quantitySold;
  final double revenue;
  final double revenueShare;
  final double? averageRating;

  TopProduct({
    required this.name,
    required this.categoryName,
    required this.quantitySold,
    required this.revenue,
    required this.revenueShare,
    required this.averageRating,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) => TopProduct(
        name: json['name'] as String,
        categoryName: json['categoryName'] as String,
        quantitySold: json['quantitySold'] as int,
        revenue: (json['revenue'] as num).toDouble(),
        revenueShare: (json['revenueShare'] as num).toDouble(),
        averageRating: (json['averageRating'] as num?)?.toDouble(),
      );
}

class InventoryReport {
  final List<InventoryItem> items;
  final List<WorstRatedProduct> worstRated;
  final double totalValue;
  final int totalItems;
  final int lowStockCount;
  final int outOfStockCount;
  final int noSalesLast30Count;

  InventoryReport({
    required this.items,
    required this.worstRated,
    required this.totalValue,
    required this.totalItems,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.noSalesLast30Count,
  });

  factory InventoryReport.fromJson(Map<String, dynamic> json) => InventoryReport(
        items: (json['items'] as List)
            .map((item) => InventoryItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        worstRated: (json['worstRated'] as List)
            .map((item) =>
                WorstRatedProduct.fromJson(item as Map<String, dynamic>))
            .toList(),
        totalValue: (json['totalValue'] as num).toDouble(),
        totalItems: json['totalItems'] as int,
        lowStockCount: json['lowStockCount'] as int,
        outOfStockCount: json['outOfStockCount'] as int,
        noSalesLast30Count: json['noSalesLast30Count'] as int,
      );
}

class InventoryItem {
  final String name;
  final String categoryName;
  final String supplierName;
  final int stockQuantity;
  final int soldLast30Days;
  final double price;
  final double stockValue;
  final double? stockCoverDays;

  InventoryItem({
    required this.name,
    required this.categoryName,
    required this.supplierName,
    required this.stockQuantity,
    required this.soldLast30Days,
    required this.price,
    required this.stockValue,
    required this.stockCoverDays,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        name: json['name'] as String,
        categoryName: json['categoryName'] as String,
        supplierName: json['supplierName'] as String,
        stockQuantity: json['stockQuantity'] as int,
        soldLast30Days: json['soldLast30Days'] as int,
        price: (json['price'] as num).toDouble(),
        stockValue: (json['stockValue'] as num).toDouble(),
        stockCoverDays: (json['stockCoverDays'] as num?)?.toDouble(),
      );
}

class WorstRatedProduct {
  final String name;
  final double averageRating;
  final int reviewCount;
  final int soldLast30Days;

  WorstRatedProduct({
    required this.name,
    required this.averageRating,
    required this.reviewCount,
    required this.soldLast30Days,
  });

  factory WorstRatedProduct.fromJson(Map<String, dynamic> json) =>
      WorstRatedProduct(
        name: json['name'] as String,
        averageRating: (json['averageRating'] as num).toDouble(),
        reviewCount: json['reviewCount'] as int,
        soldLast30Days: json['soldLast30Days'] as int,
      );
}

class MembershipReport {
  final int activeCount;
  final int expiringIn7Days;
  final int newMembersThisMonth;
  final double renewalRatePercent;
  final List<PackageStat> packages;
  final List<WeeklyVisitCount> weeklyVisits;
  final List<HourlyVisitCount> visitsByHour;
  final double avgVisitDurationMinutes;
  final double avgVisitsPerActiveMember;

  MembershipReport({
    required this.activeCount,
    required this.expiringIn7Days,
    required this.newMembersThisMonth,
    required this.renewalRatePercent,
    required this.packages,
    required this.weeklyVisits,
    required this.visitsByHour,
    required this.avgVisitDurationMinutes,
    required this.avgVisitsPerActiveMember,
  });

  factory MembershipReport.fromJson(Map<String, dynamic> json) => MembershipReport(
        activeCount: json['activeCount'] as int,
        expiringIn7Days: json['expiringIn7Days'] as int,
        newMembersThisMonth: json['newMembersThisMonth'] as int,
        renewalRatePercent: (json['renewalRatePercent'] as num).toDouble(),
        packages: (json['packages'] as List)
            .map((item) => PackageStat.fromJson(item as Map<String, dynamic>))
            .toList(),
        weeklyVisits: (json['weeklyVisits'] as List)
            .map((item) =>
                WeeklyVisitCount.fromJson(item as Map<String, dynamic>))
            .toList(),
        visitsByHour: (json['visitsByHour'] as List)
            .map((item) =>
                HourlyVisitCount.fromJson(item as Map<String, dynamic>))
            .toList(),
        avgVisitDurationMinutes:
            (json['avgVisitDurationMinutes'] as num).toDouble(),
        avgVisitsPerActiveMember:
            (json['avgVisitsPerActiveMember'] as num).toDouble(),
      );
}

class PackageStat {
  final String packageName;
  final int activeCount;
  final int soldLast6Months;
  final double revenue;

  PackageStat({
    required this.packageName,
    required this.activeCount,
    required this.soldLast6Months,
    required this.revenue,
  });

  factory PackageStat.fromJson(Map<String, dynamic> json) => PackageStat(
        packageName: json['packageName'] as String,
        activeCount: json['activeCount'] as int,
        soldLast6Months: json['soldLast6Months'] as int,
        revenue: (json['revenue'] as num).toDouble(),
      );
}

class HourlyVisitCount {
  final int hour;
  final int count;

  HourlyVisitCount({required this.hour, required this.count});

  factory HourlyVisitCount.fromJson(Map<String, dynamic> json) =>
      HourlyVisitCount(
        hour: json['hour'] as int,
        count: json['count'] as int,
      );
}

class WeeklyVisitCount {
  final DateTime weekStart;
  final int count;

  WeeklyVisitCount({required this.weekStart, required this.count});

  factory WeeklyVisitCount.fromJson(Map<String, dynamic> json) =>
      WeeklyVisitCount(
        weekStart: DateTime.parse(json['weekStart'] as String),
        count: json['count'] as int,
      );
}

class ActivityLogEntry {
  final int id;
  final String entityName;
  final String? entityDisplay;
  final String action;
  final String performedByName;
  final DateTime timestamp;
  final bool canUndo;

  ActivityLogEntry({
    required this.id,
    required this.entityName,
    this.entityDisplay,
    required this.action,
    required this.performedByName,
    required this.timestamp,
    required this.canUndo,
  });

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) =>
      ActivityLogEntry(
        id: json['id'] as int,
        entityName: json['entityName'] as String,
        entityDisplay: json['entityDisplay'] as String?,
        action: json['action'] as String,
        performedByName: json['performedByName'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        canUndo: json['canUndo'] as bool,
      );
}

class LeaderboardEntry {
  final int rank;
  final String fullName;
  final String username;
  final int xp;
  final int level;
  final int visitCount;
  final int totalHours;

  LeaderboardEntry({
    required this.rank,
    required this.fullName,
    required this.username,
    required this.xp,
    required this.level,
    required this.visitCount,
    required this.totalHours,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        rank: json['rank'] as int,
        fullName: json['fullName'] as String,
        username: json['username'] as String,
        xp: json['xp'] as int,
        level: json['level'] as int,
        visitCount: json['visitCount'] as int,
        totalHours: json['totalHours'] as int,
      );
}
