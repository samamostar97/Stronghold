import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/notification_response.dart';

class NotificationsRepository {
  final Dio _dio = ApiClient.instance;

  Future<PagedNotificationResponse> getNotifications({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get('/notifications', queryParameters: {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'orderDescending': true,
      });
      return PagedNotificationResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _dio.put('/notifications/$id/read');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.put('/notifications/read-all');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
