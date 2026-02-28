import '../api/api_client.dart';
import '../models/responses/dashboard_attention_dto.dart';
import '../models/responses/dashboard_sales_dto.dart';
import '../models/responses/dashboard_overview_dto.dart';

/// Dashboard-focused read service for admin home screen widgets.
class DashboardService {
  final ApiClient _client;

  DashboardService(this._client);

  /// Returns aggregated dashboard overview metrics.
  Future<DashboardOverviewDTO> getOverview({int days = 30}) async {
    return _client.get<DashboardOverviewDTO>(
      '/api/dashboard/overview',
      queryParameters: {'days': days.toString()},
      parser: (json) => DashboardOverviewDTO.fromJson(json),
    );
  }

  /// Returns lightweight daily sales for the dashboard chart.
  Future<DashboardSalesDTO> getSales() async {
    return _client.get<DashboardSalesDTO>(
      '/api/dashboard/sales',
      parser: (json) => DashboardSalesDTO.fromJson(json),
    );
  }

  /// Returns dashboard attention counters (pending orders, expiring memberships).
  Future<DashboardAttentionDTO> getAttention({int days = 7}) async {
    return _client.get<DashboardAttentionDTO>(
      '/api/dashboard/attention',
      queryParameters: {'days': days.toString()},
      parser: (json) => DashboardAttentionDTO.fromJson(json),
    );
  }
}
