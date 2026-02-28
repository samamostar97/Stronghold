import 'business_report_dto.dart';

class DashboardSalesDTO {
  final List<DailySalesDTO> dailySales;
  final num totalRevenue;
  final int totalOrders;

  DashboardSalesDTO({
    required this.dailySales,
    required this.totalRevenue,
    required this.totalOrders,
  });

  factory DashboardSalesDTO.fromJson(Map<String, dynamic> json) {
    final sales = (json['dailySales'] as List<dynamic>?)
            ?.map((e) => DailySalesDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <DailySalesDTO>[];

    return DashboardSalesDTO(
      dailySales: sales,
      totalRevenue: (json['totalRevenue'] ?? 0) as num,
      totalOrders: (json['totalOrders'] ?? 0) as int,
    );
  }
}
