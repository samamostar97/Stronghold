// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RevenueReportData _$RevenueReportDataFromJson(Map<String, dynamic> json) =>
    _RevenueReportData(
      from: DateTime.parse(json['from'] as String),
      to: DateTime.parse(json['to'] as String),
      orderRevenue: (json['orderRevenue'] as num).toDouble(),
      membershipRevenue: (json['membershipRevenue'] as num).toDouble(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      orderCount: (json['orderCount'] as num).toInt(),
      membershipCount: (json['membershipCount'] as num).toInt(),
    );

Map<String, dynamic> _$RevenueReportDataToJson(_RevenueReportData instance) =>
    <String, dynamic>{
      'from': instance.from.toIso8601String(),
      'to': instance.to.toIso8601String(),
      'orderRevenue': instance.orderRevenue,
      'membershipRevenue': instance.membershipRevenue,
      'totalRevenue': instance.totalRevenue,
      'orderCount': instance.orderCount,
      'membershipCount': instance.membershipCount,
    };

_OrderRevenueReportData _$OrderRevenueReportDataFromJson(
  Map<String, dynamic> json,
) => _OrderRevenueReportData(
  from: DateTime.parse(json['from'] as String),
  to: DateTime.parse(json['to'] as String),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  totalOrders: (json['totalOrders'] as num).toInt(),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => OrderRevenueItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$OrderRevenueReportDataToJson(
  _OrderRevenueReportData instance,
) => <String, dynamic>{
  'from': instance.from.toIso8601String(),
  'to': instance.to.toIso8601String(),
  'totalRevenue': instance.totalRevenue,
  'totalOrders': instance.totalOrders,
  'items': instance.items,
};

_OrderRevenueItem _$OrderRevenueItemFromJson(Map<String, dynamic> json) =>
    _OrderRevenueItem(
      orderId: (json['orderId'] as num).toInt(),
      userName: json['userName'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$OrderRevenueItemToJson(_OrderRevenueItem instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'userName': instance.userName,
      'totalAmount': instance.totalAmount,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_MembershipRevenueReportData _$MembershipRevenueReportDataFromJson(
  Map<String, dynamic> json,
) => _MembershipRevenueReportData(
  from: DateTime.parse(json['from'] as String),
  to: DateTime.parse(json['to'] as String),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  totalMemberships: (json['totalMemberships'] as num).toInt(),
  items:
      (json['items'] as List<dynamic>?)
          ?.map(
            (e) => MembershipRevenueItem.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$MembershipRevenueReportDataToJson(
  _MembershipRevenueReportData instance,
) => <String, dynamic>{
  'from': instance.from.toIso8601String(),
  'to': instance.to.toIso8601String(),
  'totalRevenue': instance.totalRevenue,
  'totalMemberships': instance.totalMemberships,
  'items': instance.items,
};

_MembershipRevenueItem _$MembershipRevenueItemFromJson(
  Map<String, dynamic> json,
) => _MembershipRevenueItem(
  membershipId: (json['membershipId'] as num).toInt(),
  userName: json['userName'] as String,
  packageName: json['packageName'] as String,
  price: (json['price'] as num).toDouble(),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
);

Map<String, dynamic> _$MembershipRevenueItemToJson(
  _MembershipRevenueItem instance,
) => <String, dynamic>{
  'membershipId': instance.membershipId,
  'userName': instance.userName,
  'packageName': instance.packageName,
  'price': instance.price,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
};

_UsersReportData _$UsersReportDataFromJson(Map<String, dynamic> json) =>
    _UsersReportData(
      from: DateTime.parse(json['from'] as String),
      to: DateTime.parse(json['to'] as String),
      totalNewUsers: (json['totalNewUsers'] as num).toInt(),
      users:
          (json['users'] as List<dynamic>?)
              ?.map((e) => UserReportItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UsersReportDataToJson(_UsersReportData instance) =>
    <String, dynamic>{
      'from': instance.from.toIso8601String(),
      'to': instance.to.toIso8601String(),
      'totalNewUsers': instance.totalNewUsers,
      'users': instance.users,
    };

_UserReportItem _$UserReportItemFromJson(Map<String, dynamic> json) =>
    _UserReportItem(
      id: (json['id'] as num).toInt(),
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserReportItemToJson(_UserReportItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'email': instance.email,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_ProductsReportData _$ProductsReportDataFromJson(Map<String, dynamic> json) =>
    _ProductsReportData(
      from: DateTime.parse(json['from'] as String),
      to: DateTime.parse(json['to'] as String),
      topSelling:
          (json['topSelling'] as List<dynamic>?)
              ?.map(
                (e) =>
                    TopSellingProductItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      stockLevels:
          (json['stockLevels'] as List<dynamic>?)
              ?.map((e) => StockLevelItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProductsReportDataToJson(_ProductsReportData instance) =>
    <String, dynamic>{
      'from': instance.from.toIso8601String(),
      'to': instance.to.toIso8601String(),
      'topSelling': instance.topSelling,
      'stockLevels': instance.stockLevels,
    };

_TopSellingProductItem _$TopSellingProductItemFromJson(
  Map<String, dynamic> json,
) => _TopSellingProductItem(
  productId: (json['productId'] as num).toInt(),
  productName: json['productName'] as String,
  categoryName: json['categoryName'] as String,
  totalQuantitySold: (json['totalQuantitySold'] as num).toInt(),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
);

Map<String, dynamic> _$TopSellingProductItemToJson(
  _TopSellingProductItem instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'productName': instance.productName,
  'categoryName': instance.categoryName,
  'totalQuantitySold': instance.totalQuantitySold,
  'totalRevenue': instance.totalRevenue,
};

_StockLevelItem _$StockLevelItemFromJson(Map<String, dynamic> json) =>
    _StockLevelItem(
      productId: (json['productId'] as num).toInt(),
      productName: json['productName'] as String,
      categoryName: json['categoryName'] as String,
      stockQuantity: (json['stockQuantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$StockLevelItemToJson(_StockLevelItem instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'categoryName': instance.categoryName,
      'stockQuantity': instance.stockQuantity,
      'price': instance.price,
    };

_AppointmentsReportData _$AppointmentsReportDataFromJson(
  Map<String, dynamic> json,
) => _AppointmentsReportData(
  from: DateTime.parse(json['from'] as String),
  to: DateTime.parse(json['to'] as String),
  totalAppointments: (json['totalAppointments'] as num).toInt(),
  staffStats:
      (json['staffStats'] as List<dynamic>?)
          ?.map((e) => StaffAppointmentItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$AppointmentsReportDataToJson(
  _AppointmentsReportData instance,
) => <String, dynamic>{
  'from': instance.from.toIso8601String(),
  'to': instance.to.toIso8601String(),
  'totalAppointments': instance.totalAppointments,
  'staffStats': instance.staffStats,
};

_StaffAppointmentItem _$StaffAppointmentItemFromJson(
  Map<String, dynamic> json,
) => _StaffAppointmentItem(
  staffId: (json['staffId'] as num).toInt(),
  staffName: json['staffName'] as String,
  staffType: json['staffType'] as String,
  totalAppointments: (json['totalAppointments'] as num).toInt(),
  completed: (json['completed'] as num).toInt(),
  approved: (json['approved'] as num).toInt(),
  rejected: (json['rejected'] as num).toInt(),
  pending: (json['pending'] as num).toInt(),
);

Map<String, dynamic> _$StaffAppointmentItemToJson(
  _StaffAppointmentItem instance,
) => <String, dynamic>{
  'staffId': instance.staffId,
  'staffName': instance.staffName,
  'staffType': instance.staffType,
  'totalAppointments': instance.totalAppointments,
  'completed': instance.completed,
  'approved': instance.approved,
  'rejected': instance.rejected,
  'pending': instance.pending,
};
