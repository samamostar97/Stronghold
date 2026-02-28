import '../api/api_client.dart';
import '../models/responses/business_report_dto.dart';
import '../models/responses/dashboard_sales_dto.dart';

/// Dashboard-focused read service for admin home screen widgets.
class DashboardService {
  final ApiClient _client;

  DashboardService(this._client);

  /// Returns aggregated dashboard overview metrics.
  ///
  /// Backend currently serves this data from the reports module.
  Future<BusinessReportDTO> getOverview({int days = 30}) async {
    return _client.get<BusinessReportDTO>(
      '/api/reports/business',
      queryParameters: {'days': days.toString()},
      parser: (json) => BusinessReportDTO.fromJson(json),
    );
  }

  /// Returns lightweight daily sales for the dashboard chart.
  Future<DashboardSalesDTO> getSales() async {
    return _client.get<DashboardSalesDTO>(
      '/api/reports/dashboard/sales',
      parser: (json) => DashboardSalesDTO.fromJson(json),
    );
  }
}
