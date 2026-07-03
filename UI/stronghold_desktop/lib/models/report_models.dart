/// Modeli dashboarda i biznis reporta.
class Dashboard {
  final int activeMembers;
  final int visitsToday;
  final int currentlyInGym;
  final double revenueThisMonth;
  final List<DashboardOrder> latestOrders;

  Dashboard({
    required this.activeMembers,
    required this.visitsToday,
    required this.currentlyInGym,
    required this.revenueThisMonth,
    required this.latestOrders,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) => Dashboard(
        activeMembers: json['activeMembers'] as int,
        visitsToday: json['visitsToday'] as int,
        currentlyInGym: json['currentlyInGym'] as int,
        revenueThisMonth: (json['revenueThisMonth'] as num).toDouble(),
        latestOrders: (json['latestOrders'] as List)
            .map((item) => DashboardOrder.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class DashboardOrder {
  final int id;
  final String userFullName;
  final DateTime createdAt;
  final double totalAmount;
  final String status;

  DashboardOrder({
    required this.id,
    required this.userFullName,
    required this.createdAt,
    required this.totalAmount,
    required this.status,
  });

  factory DashboardOrder.fromJson(Map<String, dynamic> json) => DashboardOrder(
        id: json['id'] as int,
        userFullName: json['userFullName'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        status: json['status'] as String,
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
  final int quantitySold;
  final double revenue;

  TopProduct({
    required this.name,
    required this.quantitySold,
    required this.revenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) => TopProduct(
        name: json['name'] as String,
        quantitySold: json['quantitySold'] as int,
        revenue: (json['revenue'] as num).toDouble(),
      );
}

class InventoryReport {
  final List<InventoryItem> items;
  final double totalValue;
  final int lowStockCount;

  InventoryReport({
    required this.items,
    required this.totalValue,
    required this.lowStockCount,
  });

  factory InventoryReport.fromJson(Map<String, dynamic> json) => InventoryReport(
        items: (json['items'] as List)
            .map((item) => InventoryItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        totalValue: (json['totalValue'] as num).toDouble(),
        lowStockCount: json['lowStockCount'] as int,
      );
}

class InventoryItem {
  final String name;
  final String categoryName;
  final String supplierName;
  final int stockQuantity;
  final double price;
  final double stockValue;

  InventoryItem({
    required this.name,
    required this.categoryName,
    required this.supplierName,
    required this.stockQuantity,
    required this.price,
    required this.stockValue,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        name: json['name'] as String,
        categoryName: json['categoryName'] as String,
        supplierName: json['supplierName'] as String,
        stockQuantity: json['stockQuantity'] as int,
        price: (json['price'] as num).toDouble(),
        stockValue: (json['stockValue'] as num).toDouble(),
      );
}

class MembershipReport {
  final int activeCount;
  final int expiringIn7Days;
  final List<PackageDistribution> byPackage;
  final List<WeeklyVisitCount> weeklyVisits;

  MembershipReport({
    required this.activeCount,
    required this.expiringIn7Days,
    required this.byPackage,
    required this.weeklyVisits,
  });

  factory MembershipReport.fromJson(Map<String, dynamic> json) => MembershipReport(
        activeCount: json['activeCount'] as int,
        expiringIn7Days: json['expiringIn7Days'] as int,
        byPackage: (json['byPackage'] as List)
            .map((item) =>
                PackageDistribution.fromJson(item as Map<String, dynamic>))
            .toList(),
        weeklyVisits: (json['weeklyVisits'] as List)
            .map((item) =>
                WeeklyVisitCount.fromJson(item as Map<String, dynamic>))
            .toList(),
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
