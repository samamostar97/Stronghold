import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';

class UsersRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<Map<String, dynamic>>> searchUsers(String search) async {
    try {
      final response = await _dio.get('/users', queryParameters: {
        'search': search,
        'pageSize': 10,
      });
      final data = response.data as Map<String, dynamic>;
      return (data['items'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository();
});
