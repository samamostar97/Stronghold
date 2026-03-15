import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/audit_log_response.dart';

class AuditLogsRepository {
  final Dio _dio = ApiClient.instance;

  Future<PagedAuditLogResponse> getAuditLogs({
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
    String? entityType,
    String? orderBy,
    bool orderDescending = true,
  }) async {
    try {
      final params = <String, dynamic>{
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'orderDescending': orderDescending,
      };
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (entityType != null && entityType.isNotEmpty) {
        params['entityType'] = entityType;
      }
      if (orderBy != null) params['orderBy'] = orderBy;

      final response =
          await _dio.get('/audit-logs', queryParameters: params);
      return PagedAuditLogResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> undoDelete(int id) async {
    try {
      await _dio.post('/audit-logs/$id/undo');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
