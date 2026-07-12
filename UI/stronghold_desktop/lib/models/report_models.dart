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
  final double totalRevenue;
  final double membershipRevenue;
  final double orderRevenue;
  final int newMembers;
  final int visitCount;
  final List<MonthlyRevenue> monthlyRevenue;
  final List<TopProduct> topProducts;
  final List<PackageSales> packageSales;

  RevenueReport({
    required this.totalRevenue,
    required this.membershipRevenue,
    required this.orderRevenue,
    required this.newMembers,
    required this.visitCount,
    required this.monthlyRevenue,
    required this.topProducts,
    required this.packageSales,
  });

  factory RevenueReport.fromJson(Map<String, dynamic> json) => RevenueReport(
        totalRevenue: (json['totalRevenue'] as num).toDouble(),
        membershipRevenue: (json['membershipRevenue'] as num).toDouble(),
        orderRevenue: (json['orderRevenue'] as num).toDouble(),
        newMembers: json['newMembers'] as int,
        visitCount: json['visitCount'] as int,
        monthlyRevenue: (json['monthlyRevenue'] as List)
            .map((item) => MonthlyRevenue.fromJson(item as Map<String, dynamic>))
            .toList(),
        topProducts: (json['topProducts'] as List)
            .map((item) => TopProduct.fromJson(item as Map<String, dynamic>))
            .toList(),
        packageSales: (json['packageSales'] as List)
            .map((item) => PackageSales.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class PackageSales {
  final String packageName;
  final int soldCount;
  final double revenue;

  PackageSales({
    required this.packageName,
    required this.soldCount,
    required this.revenue,
  });

  factory PackageSales.fromJson(Map<String, dynamic> json) => PackageSales(
        packageName: json['packageName'] as String,
        soldCount: json['soldCount'] as int,
        revenue: (json['revenue'] as num).toDouble(),
      );
}

class StaffReport {
  final int totalAppointments;
  final int completedCount;
  final int cancelledCount;
  final int upcomingCount;
  final String? busiestStaffName;
  final int busiestStaffCount;
  final int? busiestHour;
  final int busiestHourCount;
  final List<StaffAppointmentStat> staff;

  StaffReport({
    required this.totalAppointments,
    required this.completedCount,
    required this.cancelledCount,
    required this.upcomingCount,
    required this.busiestStaffName,
    required this.busiestStaffCount,
    required this.busiestHour,
    required this.busiestHourCount,
    required this.staff,
  });

  factory StaffReport.fromJson(Map<String, dynamic> json) => StaffReport(
        totalAppointments: json['totalAppointments'] as int,
        completedCount: json['completedCount'] as int,
        cancelledCount: json['cancelledCount'] as int,
        upcomingCount: json['upcomingCount'] as int,
        busiestStaffName: json['busiestStaffName'] as String?,
        busiestStaffCount: json['busiestStaffCount'] as int,
        busiestHour: json['busiestHour'] as int?,
        busiestHourCount: json['busiestHourCount'] as int,
        staff: (json['staff'] as List)
            .map((item) =>
                StaffAppointmentStat.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class StaffAppointmentStat {
  final String fullName;
  final String staffType;
  final int totalCount;
  final int completedCount;
  final int cancelledCount;
  final int upcomingCount;

  StaffAppointmentStat({
    required this.fullName,
    required this.staffType,
    required this.totalCount,
    required this.completedCount,
    required this.cancelledCount,
    required this.upcomingCount,
  });

  factory StaffAppointmentStat.fromJson(Map<String, dynamic> json) =>
      StaffAppointmentStat(
        fullName: json['fullName'] as String,
        staffType: json['staffType'] as String,
        totalCount: json['totalCount'] as int,
        completedCount: json['completedCount'] as int,
        cancelledCount: json['cancelledCount'] as int,
        upcomingCount: json['upcomingCount'] as int,
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

  TopProduct({
    required this.name,
    required this.categoryName,
    required this.quantitySold,
    required this.revenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) => TopProduct(
        name: json['name'] as String,
        categoryName: json['categoryName'] as String,
        quantitySold: json['quantitySold'] as int,
        revenue: (json['revenue'] as num).toDouble(),
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
