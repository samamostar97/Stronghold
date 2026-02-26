import 'dart:io';
import '../api/api_client.dart';
import '../models/common/paged_result.dart';
import '../models/filters/slow_moving_product_query_filter.dart';
import '../models/responses/business_report_dto.dart';

/// Reports service using the generic ApiClient
class ReportsService {
  final ApiClient _client;

  ReportsService(this._client);

  /// Get business report with statistics
  Future<BusinessReportDTO> getBusinessReport({int days = 30}) async {
    return _client.get<BusinessReportDTO>(
      '/api/reports/business',
      queryParameters: {'days': days.toString()},
      parser: (json) => BusinessReportDTO.fromJson(json),
    );
  }

  /// Get inventory report (slow moving products) - legacy, all at once
  Future<InventoryReportDTO> getInventoryReport({int daysToAnalyze = 30}) async {
    return _client.get<InventoryReportDTO>(
      '/api/reports/inventory',
      queryParameters: {'daysToAnalyze': daysToAnalyze.toString()},
      parser: (json) => InventoryReportDTO.fromJson(json),
    );
  }

  /// Get inventory summary (totals only, no products list)
  Future<InventorySummaryDTO> getInventorySummary({int daysToAnalyze = 30}) async {
    return _client.get<InventorySummaryDTO>(
      '/api/reports/inventory/summary',
      queryParameters: {'daysToAnalyze': daysToAnalyze.toString()},
      parser: (json) => InventorySummaryDTO.fromJson(json),
    );
  }

  /// Get slow-moving products with pagination
  Future<PagedResult<SlowMovingProductDTO>> getSlowMovingProductsPaged(
    SlowMovingProductQueryFilter filter,
  ) async {
    return _client.get<PagedResult<SlowMovingProductDTO>>(
      '/api/reports/inventory/slow-moving',
      queryParameters: filter.toQueryParameters(),
      parser: (json) => PagedResult.fromJson(
        json,
        (item) => SlowMovingProductDTO.fromJson(item),
      ),
    );
  }

  /// Get membership popularity report
  Future<MembershipPopularityReportDTO> getMembershipPopularityReport({int days = 90}) async {
    return _client.get<MembershipPopularityReportDTO>(
      '/api/reports/membership-popularity',
      queryParameters: {'days': days.toString()},
      parser: (json) => MembershipPopularityReportDTO.fromJson(json),
    );
  }

  /// Get activity feed
  Future<List<ActivityFeedItemDTO>> getActivityFeed({int count = 20}) async {
    return _client.get<List<ActivityFeedItemDTO>>(
      '/api/reports/activity',
      queryParameters: {'count': count.toString()},
      parser: (json) => (json as List<dynamic>)
          .map((e) => ActivityFeedItemDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Build date range query parameters
  Map<String, String> _dateRangeParams({DateTime? from, DateTime? to}) {
    final qp = <String, String>{};
    if (from != null) qp['from'] = from.toIso8601String();
    if (to != null) qp['to'] = to.toIso8601String();
    return qp;
  }

  /// Export business report to Excel and save to file
  Future<void> exportBusinessToExcel(String savePath, {DateTime? from, DateTime? to}) async {
    final bytes = await _client.getBytes(
      '/api/reports/export/excel',
      queryParameters: _dateRangeParams(from: from, to: to),
    );
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }

  /// Export business report to PDF and save to file
  Future<void> exportBusinessToPdf(String savePath, {DateTime? from, DateTime? to}) async {
    final bytes = await _client.getBytes(
      '/api/reports/export/pdf',
      queryParameters: _dateRangeParams(from: from, to: to),
    );
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }

  /// Export inventory report to Excel
  Future<void> exportInventoryToExcel(String savePath, {int daysToAnalyze = 30, DateTime? from, DateTime? to}) async {
    final qp = <String, String>{'daysToAnalyze': daysToAnalyze.toString()};
    qp.addAll(_dateRangeParams(from: from, to: to));
    final bytes = await _client.getBytes(
      '/api/reports/inventory/export/excel',
      queryParameters: qp,
    );
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }

  /// Export inventory report to PDF
  Future<void> exportInventoryToPdf(String savePath, {int daysToAnalyze = 30, DateTime? from, DateTime? to}) async {
    final qp = <String, String>{'daysToAnalyze': daysToAnalyze.toString()};
    qp.addAll(_dateRangeParams(from: from, to: to));
    final bytes = await _client.getBytes(
      '/api/reports/inventory/export/pdf',
      queryParameters: qp,
    );
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }

  /// Export membership popularity report to Excel
  Future<void> exportMembershipToExcel(String savePath, {DateTime? from, DateTime? to}) async {
    final bytes = await _client.getBytes(
      '/api/reports/membership-popularity/export/excel',
      queryParameters: _dateRangeParams(from: from, to: to),
    );
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }

  /// Export membership popularity report to PDF
  Future<void> exportMembershipToPdf(String savePath, {DateTime? from, DateTime? to}) async {
    final bytes = await _client.getBytes(
      '/api/reports/membership-popularity/export/pdf',
      queryParameters: _dateRangeParams(from: from, to: to),
    );
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }
}
