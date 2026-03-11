import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/product_category_response.dart';

class ProductCategoriesRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<ProductCategoryResponse>> getCategories() async {
    try {
      final response = await _dio.get('/product-categories');
      final list = response.data as List<dynamic>;
      return list
          .map((e) =>
              ProductCategoryResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ProductCategoryResponse> getCategoryById(int id) async {
    try {
      final response = await _dio.get('/product-categories/$id');
      return ProductCategoryResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ProductCategoryResponse> createCategory({
    required String name,
    String? description,
  }) async {
    try {
      final response = await _dio.post('/product-categories', data: {
        'name': name,
        'description': description,
      });
      return ProductCategoryResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ProductCategoryResponse> updateCategory({
    required int id,
    required String name,
    String? description,
  }) async {
    try {
      final response = await _dio.put('/product-categories/$id', data: {
        'name': name,
        'description': description,
      });
      return ProductCategoryResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _dio.delete('/product-categories/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
