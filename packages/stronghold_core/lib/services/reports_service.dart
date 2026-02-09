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
  Future<BusinessReportDTO> getBusinessReport() async {
    return _client.get<BusinessReportDTO>(
      '/api/reports/business',
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
  Future<MembershipPopularityReportDTO> getMembershipPopularityReport() async {
    return _client.get<MembershipPopularityReportDTO>(
      '/api/reports/membership-popularity',
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

  /// Export business report to Excel and save to file
  Future<void> exportBusinessToExcel(String savePath) async {
    final bytes = await _client.getBytes('/api/reports/export/excel');
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }

  /// Export business report to PDF and save to file
  Future<void> exportBusinessToPdf(String savePath) async {
    final bytes = await _client.getBytes('/api/reports/export/pdf');
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }

  /// Export inventory report to Excel
  Future<void> exportInventoryToExcel(String savePath, {int daysToAnalyze = 30}) async {
    final bytes = await _client.getBytes(
      '/api/reports/inventory/export/excel',
      queryParameters: {'daysToAnalyze': daysToAnalyze.toString()},
    );
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }

  /// Export inventory report to PDF
  Future<void> exportInventoryToPdf(String savePath, {int daysToAnalyze = 30}) async {
    final bytes = await _client.getBytes(
      '/api/reports/inventory/export/pdf',
      queryParameters: {'daysToAnalyze': daysToAnalyze.toString()},
    );
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }

  /// Export membership popularity report to Excel
  Future<void> exportMembershipToExcel(String savePath) async {
    final bytes = await _client.getBytes('/api/reports/membership-popularity/export/excel');
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }

  /// Export membership popularity report to PDF
  Future<void> exportMembershipToPdf(String savePath) async {
    final bytes = await _client.getBytes('/api/reports/membership-popularity/export/pdf');
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }
}
