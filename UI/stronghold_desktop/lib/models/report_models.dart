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

/// Izvjestaj o clanarinama - sve uplate u odabranom periodu.
class MembershipsReport {
  final String? userFullName;
  final double totalAmount;
  final int paymentCount;
  final List<PaymentRow> payments;

  MembershipsReport({
    required this.userFullName,
    required this.totalAmount,
    required this.paymentCount,
    required this.payments,
  });

  factory MembershipsReport.fromJson(Map<String, dynamic> json) =>
      MembershipsReport(
        userFullName: json['userFullName'] as String?,
        totalAmount: (json['totalAmount'] as num).toDouble(),
        paymentCount: json['paymentCount'] as int,
        payments: (json['payments'] as List)
            .map((item) => PaymentRow.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class PaymentRow {
  final DateTime paidAt;
  final String userFullName;
  final String packageName;
  final double amount;

  PaymentRow({
    required this.paidAt,
    required this.userFullName,
    required this.packageName,
    required this.amount,
  });

  factory PaymentRow.fromJson(Map<String, dynamic> json) => PaymentRow(
        paidAt: DateTime.parse(json['paidAt'] as String),
        userFullName: json['userFullName'] as String,
        packageName: json['packageName'] as String,
        amount: (json['amount'] as num).toDouble(),
      );
}

/// Izvjestaj o prodavnici - sve prodaje u odabranom periodu (bez otkazanih).
class ShopReport {
  final String? userFullName;
  final double totalRevenue;
  final int orderCount;
  final List<OrderRow> orders;

  ShopReport({
    required this.userFullName,
    required this.totalRevenue,
    required this.orderCount,
    required this.orders,
  });

  factory ShopReport.fromJson(Map<String, dynamic> json) => ShopReport(
        userFullName: json['userFullName'] as String?,
        totalRevenue: (json['totalRevenue'] as num).toDouble(),
        orderCount: json['orderCount'] as int,
        orders: (json['orders'] as List)
            .map((item) => OrderRow.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class OrderRow {
  final DateTime createdAt;
  final String userFullName;
  final int itemCount;
  final double totalAmount;
  final String status;

  OrderRow({
    required this.createdAt,
    required this.userFullName,
    required this.itemCount,
    required this.totalAmount,
    required this.status,
  });

  factory OrderRow.fromJson(Map<String, dynamic> json) => OrderRow(
        createdAt: DateTime.parse(json['createdAt'] as String),
        userFullName: json['userFullName'] as String,
        itemCount: json['itemCount'] as int,
        totalAmount: (json['totalAmount'] as num).toDouble(),
        status: json['status'] as String,
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
