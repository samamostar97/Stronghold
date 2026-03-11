import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/product_response.dart';

class ProductsRepository {
  final Dio _dio = ApiClient.instance;

  Future<PagedProductResponse> getProducts({
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
    int? categoryId,
    int? supplierId,
    double? minPrice,
    double? maxPrice,
    String orderBy = 'stock',
    bool orderDescending = false,
  }) async {
    try {
      final params = <String, dynamic>{
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'orderBy': orderBy,
        'orderDescending': orderDescending,
      };
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (categoryId != null) params['categoryId'] = categoryId;
      if (supplierId != null) params['supplierId'] = supplierId;
      if (minPrice != null) params['minPrice'] = minPrice;
      if (maxPrice != null) params['maxPrice'] = maxPrice;

      final response = await _dio.get('/products', queryParameters: params);
      return PagedProductResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ProductResponse> getProductById(int id) async {
    try {
      final response = await _dio.get('/products/$id');
      return ProductResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ProductResponse> createProduct({
    required String name,
    String? description,
    required double price,
    required int stockQuantity,
    required int categoryId,
    required int supplierId,
  }) async {
    try {
      final response = await _dio.post('/products', data: {
        'name': name,
        'description': description,
        'price': price,
        'stockQuantity': stockQuantity,
        'categoryId': categoryId,
        'supplierId': supplierId,
      });
      return ProductResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ProductResponse> updateProduct({
    required int id,
    required String name,
    String? description,
    required double price,
    required int stockQuantity,
    required int categoryId,
    required int supplierId,
  }) async {
    try {
      final response = await _dio.put('/products/$id', data: {
        'name': name,
        'description': description,
        'price': price,
        'stockQuantity': stockQuantity,
        'categoryId': categoryId,
        'supplierId': supplierId,
      });
      return ProductResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _dio.delete('/products/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ProductResponse> uploadProductImage({
    required int id,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await _dio.put(
        '/products/$id/image',
        data: formData,
      );
      return ProductResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
