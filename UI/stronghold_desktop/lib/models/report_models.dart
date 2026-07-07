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
  final List<MonthlyRevenue> monthlyRevenue;
  final List<TopProduct> topProducts;
  final double totalMembershipRevenue;
  final double totalOrderRevenue;

  RevenueReport({
    required this.monthlyRevenue,
    required this.topProducts,
    required this.totalMembershipRevenue,
    required this.totalOrderRevenue,
  });

  factory RevenueReport.fromJson(Map<String, dynamic> json) => RevenueReport(
        monthlyRevenue: (json['monthlyRevenue'] as List)
            .map((item) => MonthlyRevenue.fromJson(item as Map<String, dynamic>))
            .toList(),
        topProducts: (json['topProducts'] as List)
            .map((item) => TopProduct.fromJson(item as Map<String, dynamic>))
            .toList(),
        totalMembershipRevenue:
            (json['totalMembershipRevenue'] as num).toDouble(),
        totalOrderRevenue: (json['totalOrderRevenue'] as num).toDouble(),
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
  final double totalValue;
  final int totalItems;
  final int lowStockCount;
  final int outOfStockCount;

  InventoryReport({
    required this.items,
    required this.totalValue,
    required this.totalItems,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  factory InventoryReport.fromJson(Map<String, dynamic> json) => InventoryReport(
        items: (json['items'] as List)
            .map((item) => InventoryItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        totalValue: (json['totalValue'] as num).toDouble(),
        totalItems: json['totalItems'] as int,
        lowStockCount: json['lowStockCount'] as int,
        outOfStockCount: json['outOfStockCount'] as int,
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

  InventoryItem({
    required this.name,
    required this.categoryName,
    required this.supplierName,
    required this.stockQuantity,
    required this.soldLast30Days,
    required this.price,
    required this.stockValue,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        name: json['name'] as String,
        categoryName: json['categoryName'] as String,
        supplierName: json['supplierName'] as String,
        stockQuantity: json['stockQuantity'] as int,
        soldLast30Days: json['soldLast30Days'] as int,
        price: (json['price'] as num).toDouble(),
        stockValue: (json['stockValue'] as num).toDouble(),
      );
}

class MembershipReport {
  final int activeCount;
  final int expiringIn7Days;
  final int newMembersThisMonth;
  final int revokedCount;
  final List<PackageDistribution> byPackage;
  final List<PackageSales> packageSales;
  final List<WeeklyVisitCount> weeklyVisits;

  MembershipReport({
    required this.activeCount,
    required this.expiringIn7Days,
    required this.newMembersThisMonth,
    required this.revokedCount,
    required this.byPackage,
    required this.packageSales,
    required this.weeklyVisits,
  });

  factory MembershipReport.fromJson(Map<String, dynamic> json) => MembershipReport(
        activeCount: json['activeCount'] as int,
        expiringIn7Days: json['expiringIn7Days'] as int,
        newMembersThisMonth: json['newMembersThisMonth'] as int,
        revokedCount: json['revokedCount'] as int,
        byPackage: (json['byPackage'] as List)
            .map((item) =>
                PackageDistribution.fromJson(item as Map<String, dynamic>))
            .toList(),
        packageSales: (json['packageSales'] as List)
            .map((item) => PackageSales.fromJson(item as Map<String, dynamic>))
            .toList(),
        weeklyVisits: (json['weeklyVisits'] as List)
            .map((item) =>
                WeeklyVisitCount.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class PackageSales {
  final String packageName;
  final int soldCount;
  final int soldLast6Months;
  final double revenue;

  PackageSales({
    required this.packageName,
    required this.soldCount,
    required this.soldLast6Months,
    required this.revenue,
  });

  factory PackageSales.fromJson(Map<String, dynamic> json) => PackageSales(
        packageName: json['packageName'] as String,
        soldCount: json['soldCount'] as int,
        soldLast6Months: json['soldLast6Months'] as int,
        revenue: (json['revenue'] as num).toDouble(),
      );
}

class PackageDistribution {
  final String packageName;
  final int activeCount;

  PackageDistribution({required this.packageName, required this.activeCount});

  factory PackageDistribution.fromJson(Map<String, dynamic> json) =>
      PackageDistribution(
        packageName: json['packageName'] as String,
        activeCount: json['activeCount'] as int,
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
