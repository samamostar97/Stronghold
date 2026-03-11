import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/supplier_response.dart';

class SuppliersRepository {
  final Dio _dio = ApiClient.instance;

  Future<PagedSupplierResponse> getSuppliers({
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
  }) async {
    try {
      final params = <String, dynamic>{
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      };
      if (search != null && search.isNotEmpty) params['search'] = search;

      final response = await _dio.get('/suppliers', queryParameters: params);
      return PagedSupplierResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<SupplierResponse> getSupplierById(int id) async {
    try {
      final response = await _dio.get('/suppliers/$id');
      return SupplierResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<SupplierResponse> createSupplier({
    required String name,
    String? email,
    String? phone,
    String? website,
  }) async {
    try {
      final response = await _dio.post('/suppliers', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'website': website,
      });
      return SupplierResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<SupplierResponse> updateSupplier({
    required int id,
    required String name,
    String? email,
    String? phone,
    String? website,
  }) async {
    try {
      final response = await _dio.put('/suppliers/$id', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'website': website,
      });
      return SupplierResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteSupplier(int id) async {
    try {
      await _dio.delete('/suppliers/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
