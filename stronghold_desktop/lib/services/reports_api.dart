import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/business_report_dto.dart';
import 'token_storage.dart';
import 'api_helper.dart';

class ReportsApi {
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.accessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get business report with statistics
  static Future<BusinessReportDTO> getBusinessReport() async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/report/business'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return BusinessReportDTO.fromJson(json);
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Get inventory report (slow moving products)
  static Future<InventoryReportDTO> getInventoryReport({int daysToAnalyze = 30}) async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/report/inventory?daysToAnalyze=$daysToAnalyze'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return InventoryReportDTO.fromJson(json);
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Get membership popularity report
  static Future<MembershipPopularityReportDTO> getMembershipPopularityReport() async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/report/membership-popularity'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return MembershipPopularityReportDTO.fromJson(json);
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Export report to Excel and save to file
  static Future<void> exportToExcel(String savePath) async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/report/export/excel'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(res.bodyBytes);
      return;
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Export report to PDF and save to file
  static Future<void> exportToPdf(String savePath) async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/report/export/pdf'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(res.bodyBytes);
      return;
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Export inventory report to Excel
  static Future<void> exportInventoryToExcel(String savePath, {int daysToAnalyze = 30}) async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/report/inventory/export/excel?daysToAnalyze=$daysToAnalyze'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(res.bodyBytes);
      return;
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Export inventory report to PDF
  static Future<void> exportInventoryToPdf(String savePath, {int daysToAnalyze = 30}) async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/report/inventory/export/pdf?daysToAnalyze=$daysToAnalyze'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(res.bodyBytes);
      return;
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Export membership popularity report to Excel
  static Future<void> exportMembershipPopularityToExcel(String savePath) async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/report/membership-popularity/export/excel'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(res.bodyBytes);
      return;
    }

    throw Exception(extractErrorMessage(res));
  }

  /// Export membership popularity report to PDF
  static Future<void> exportMembershipPopularityToPdf(String savePath) async {
    final res = await http.get(
      ApiConfig.uri('/api/admin/report/membership-popularity/export/pdf'),
      headers: await _headers(),
    );

    if (res.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(res.bodyBytes);
      return;
    }

    throw Exception(extractErrorMessage(res));
  }
}
