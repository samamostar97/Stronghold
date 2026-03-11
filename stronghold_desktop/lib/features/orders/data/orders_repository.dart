import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/order_response.dart';

class OrdersRepository {
  final Dio _dio = ApiClient.instance;

  Future<PagedOrderResponse> getOrders({
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
    String? status,
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
      if (status != null && status.isNotEmpty) params['status'] = status;
      if (orderBy != null) params['orderBy'] = orderBy;

      final response = await _dio.get('/orders', queryParameters: params);
      return PagedOrderResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<OrderResponse> getOrderById(int id) async {
    try {
      final response = await _dio.get('/orders/$id');
      return OrderResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<OrderResponse> confirmOrder(int id) async {
    try {
      final response = await _dio.post('/orders/$id/confirm');
      return OrderResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<OrderResponse> shipOrder(int id) async {
    try {
      final response = await _dio.put('/orders/$id/ship');
      return OrderResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
