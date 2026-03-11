import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/leaderboard_response.dart';
import '../models/user_response.dart';

class UsersRepository {
  final Dio _dio = ApiClient.instance;

  Future<PagedUserResponse> getUsers({
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
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
      if (orderBy != null) params['orderBy'] = orderBy;

      final response = await _dio.get('/users', queryParameters: params);
      return PagedUserResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<PagedLeaderboardResponse> getLeaderboard({
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

      final response = await _dio.get('/leaderboard', queryParameters: params);
      return PagedLeaderboardResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

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

  Future<UserResponse> createUser({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    String? phone,
    String? address,
  }) async {
    try {
      final response = await _dio.post('/users', data: {
        'username': username,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        'phone': phone,
        'address': address,
      });
      return UserResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<UserResponse> updateUser({
    required int id,
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    String? phone,
    String? address,
  }) async {
    try {
      final response = await _dio.put('/users/$id', data: {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'phone': phone,
        'address': address,
      });
      return UserResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _dio.delete('/users/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<UserResponse> uploadProfileImage({
    required int id,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await _dio.put(
        '/users/$id/profile-image',
        data: formData,
      );
      return UserResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository();
});
