import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/business_report_dto.dart';

class ReportsApi {
  final String baseUrl;

  ReportsApi({required this.baseUrl});

  Future<BusinessReportDTO> getBusinessReport({required String token}) async {
    final uri = Uri.parse('$baseUrl/api/admin/reports/business');

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
      return BusinessReportDTO.fromJson(jsonMap);
    }

    // Debug-friendly error
    throw Exception('Business report failed: ${res.statusCode} ${res.body}');
  }
}
