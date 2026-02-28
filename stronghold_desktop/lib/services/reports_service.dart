import 'dart:io';
import 'package:stronghold_core/stronghold_core.dart';

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
  Future<InventoryReportDTO> getInventoryReport({
    int daysToAnalyze = 30,
  }) async {
    return _client.get<InventoryReportDTO>(
      '/api/reports/inventory',
      queryParameters: {'daysToAnalyze': daysToAnalyze.toString()},
      parser: (json) => InventoryReportDTO.fromJson(json),
    );
  }

  /// Get inventory summary (totals only, no products list)
  Future<InventorySummaryDTO> getInventorySummary({
    int daysToAnalyze = 30,
  }) async {
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
  Future<MembershipPopularityReportDTO> getMembershipPopularityReport({
    int days = 90,
  }) async {
    return _client.get<MembershipPopularityReportDTO>(
      '/api/reports/membership-popularity',
      queryParameters: {'days': days.toString()},
      parser: (json) => MembershipPopularityReportDTO.fromJson(json),
    );
  }

  /// Get staff report
  Future<StaffReportDTO> getStaffReport({int days = 30}) async {
    return _client.get<StaffReportDTO>(
      '/api/reports/staff',
      queryParameters: {'days': days.toString()},
      parser: (json) => StaffReportDTO.fromJson(json),
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

  /// Export membership popularity report to Excel
  Future<void> exportMembershipToExcel(String savePath) async {
    final bytes = await _client.getBytes(
      '/api/reports/membership-popularity/export/excel',
    );
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }

  /// Export membership popularity report to PDF
  Future<void> exportMembershipToPdf(String savePath) async {
    final bytes = await _client.getBytes(
      '/api/reports/membership-popularity/export/pdf',
    );
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }

  /// Export staff report to Excel
  Future<void> exportStaffToExcel(String savePath) async {
    final bytes = await _client.getBytes('/api/reports/staff/export/excel');
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }

  /// Export staff report to PDF
  Future<void> exportStaffToPdf(String savePath) async {
    final bytes = await _client.getBytes('/api/reports/staff/export/pdf');
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }

  /// Export visits report to Excel
  Future<void> exportVisitsToExcel(String savePath) async {
    final bytes = await _client.getBytes('/api/reports/visits/export/excel');
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }

  /// Export visits report to PDF
  Future<void> exportVisitsToPdf(String savePath) async {
    final bytes = await _client.getBytes('/api/reports/visits/export/pdf');
    final file = File(savePath);
    await file.writeAsBytes(bytes);
  }
}
