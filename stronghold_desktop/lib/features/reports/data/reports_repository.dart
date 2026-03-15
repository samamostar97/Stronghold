import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/report_data.dart';

class ReportsRepository {
  final Dio _dio = ApiClient.instance;

  Future<RevenueReportData> getRevenueReport({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final response = await _dio.get('/reports/revenue', queryParameters: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
        'format': 'json',
      });
      return RevenueReportData.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<OrderRevenueReportData> getOrderRevenueReport({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final response =
          await _dio.get('/reports/revenue/orders', queryParameters: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
        'format': 'json',
      });
      return OrderRevenueReportData.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<MembershipRevenueReportData> getMembershipRevenueReport({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final response =
          await _dio.get('/reports/revenue/memberships', queryParameters: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
        'format': 'json',
      });
      return MembershipRevenueReportData.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<UsersReportData> getUsersReport({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final response = await _dio.get('/reports/users', queryParameters: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
        'format': 'json',
      });
      return UsersReportData.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ProductsReportData> getProductsReport({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final response = await _dio.get('/reports/products', queryParameters: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
        'format': 'json',
      });
      return ProductsReportData.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AppointmentsReportData> getAppointmentsReport({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final response =
          await _dio.get('/reports/appointments', queryParameters: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
        'format': 'json',
      });
      return AppointmentsReportData.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Response> downloadReport({
    required String endpoint,
    required DateTime from,
    required DateTime to,
    required String format,
  }) async {
    try {
      return await _dio.get(
        endpoint,
        queryParameters: {
          'from': from.toIso8601String(),
          'to': to.toIso8601String(),
          'format': format,
        },
        options: Options(responseType: ResponseType.bytes),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
