import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_data.freezed.dart';
part 'report_data.g.dart';

// Revenue Report
@freezed
abstract class RevenueReportData with _$RevenueReportData {
  const factory RevenueReportData({
    required DateTime from,
    required DateTime to,
    required double orderRevenue,
    required double membershipRevenue,
    required double totalRevenue,
    required int orderCount,
    required int membershipCount,
    @Default([]) List<OrderRevenueItem> orderItems,
    @Default([]) List<MembershipRevenueItem> membershipItems,
  }) = _RevenueReportData;

  factory RevenueReportData.fromJson(Map<String, dynamic> json) =>
      _$RevenueReportDataFromJson(json);
}

// Order Revenue Report
@freezed
abstract class OrderRevenueReportData with _$OrderRevenueReportData {
  const factory OrderRevenueReportData({
    required DateTime from,
    required DateTime to,
    required double totalRevenue,
    required int totalOrders,
    @Default([]) List<OrderRevenueItem> items,
  }) = _OrderRevenueReportData;

  factory OrderRevenueReportData.fromJson(Map<String, dynamic> json) =>
      _$OrderRevenueReportDataFromJson(json);
}

@freezed
abstract class OrderRevenueItem with _$OrderRevenueItem {
  const factory OrderRevenueItem({
    required int orderId,
    required String userName,
    required double totalAmount,
    required String status,
    required DateTime createdAt,
  }) = _OrderRevenueItem;

  factory OrderRevenueItem.fromJson(Map<String, dynamic> json) =>
      _$OrderRevenueItemFromJson(json);
}

// Membership Revenue Report
@freezed
abstract class MembershipRevenueReportData with _$MembershipRevenueReportData {
  const factory MembershipRevenueReportData({
    required DateTime from,
    required DateTime to,
    required double totalRevenue,
    required int totalMemberships,
    @Default([]) List<MembershipRevenueItem> items,
  }) = _MembershipRevenueReportData;

  factory MembershipRevenueReportData.fromJson(Map<String, dynamic> json) =>
      _$MembershipRevenueReportDataFromJson(json);
}

@freezed
abstract class MembershipRevenueItem with _$MembershipRevenueItem {
  const factory MembershipRevenueItem({
    required int membershipId,
    required String userName,
    required String packageName,
    required double price,
    required DateTime startDate,
    required DateTime endDate,
  }) = _MembershipRevenueItem;

  factory MembershipRevenueItem.fromJson(Map<String, dynamic> json) =>
      _$MembershipRevenueItemFromJson(json);
}

// Users Report
@freezed
abstract class UsersReportData with _$UsersReportData {
  const factory UsersReportData({
    required DateTime from,
    required DateTime to,
    required int totalNewUsers,
    @Default([]) List<UserReportItem> users,
  }) = _UsersReportData;

  factory UsersReportData.fromJson(Map<String, dynamic> json) =>
      _$UsersReportDataFromJson(json);
}

@freezed
abstract class UserReportItem with _$UserReportItem {
  const factory UserReportItem({
    required int id,
    required String fullName,
    required String email,
    required DateTime createdAt,
  }) = _UserReportItem;

  factory UserReportItem.fromJson(Map<String, dynamic> json) =>
      _$UserReportItemFromJson(json);
}

// Products Report
@freezed
abstract class ProductsReportData with _$ProductsReportData {
  const factory ProductsReportData({
    required DateTime from,
    required DateTime to,
    @Default([]) List<TopSellingProductItem> topSelling,
    @Default([]) List<StockLevelItem> stockLevels,
  }) = _ProductsReportData;

  factory ProductsReportData.fromJson(Map<String, dynamic> json) =>
      _$ProductsReportDataFromJson(json);
}

@freezed
abstract class TopSellingProductItem with _$TopSellingProductItem {
  const factory TopSellingProductItem({
    required int productId,
    required String productName,
    required String categoryName,
    required int totalQuantitySold,
    required double totalRevenue,
  }) = _TopSellingProductItem;

  factory TopSellingProductItem.fromJson(Map<String, dynamic> json) =>
      _$TopSellingProductItemFromJson(json);
}

@freezed
abstract class StockLevelItem with _$StockLevelItem {
  const factory StockLevelItem({
    required int productId,
    required String productName,
    required String categoryName,
    required int stockQuantity,
    required double price,
  }) = _StockLevelItem;

  factory StockLevelItem.fromJson(Map<String, dynamic> json) =>
      _$StockLevelItemFromJson(json);
}

// Appointments Report
@freezed
abstract class AppointmentsReportData with _$AppointmentsReportData {
  const factory AppointmentsReportData({
    required DateTime from,
    required DateTime to,
    required int totalAppointments,
    @Default([]) List<StaffAppointmentItem> staffStats,
  }) = _AppointmentsReportData;

  factory AppointmentsReportData.fromJson(Map<String, dynamic> json) =>
      _$AppointmentsReportDataFromJson(json);
}

@freezed
abstract class StaffAppointmentItem with _$StaffAppointmentItem {
  const factory StaffAppointmentItem({
    required int staffId,
    required String staffName,
    required String staffType,
    required int totalAppointments,
    required int completed,
    required int approved,
    required int rejected,
    required int pending,
  }) = _StaffAppointmentItem;

  factory StaffAppointmentItem.fromJson(Map<String, dynamic> json) =>
      _$StaffAppointmentItemFromJson(json);
}
