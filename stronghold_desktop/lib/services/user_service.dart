import 'package:stronghold_core/stronghold_core.dart';

class UserService {
  final ApiClient _client;
  static const String _path = '/api/users';

  UserService(this._client);

  Future<PagedResult<UserResponse>> getAll(UserQueryFilter filter) {
    return _client.get<PagedResult<UserResponse>>(
      _path,
      queryParameters: filter.toQueryParameters(),
      parser: (json) => PagedResult.fromJson(json as Map<String, dynamic>, UserResponse.fromJson),
    );
  }

  Future<List<UserResponse>> getAllUnpaged(UserQueryFilter filter) {
    return _client.get<List<UserResponse>>(
      '$_path/all',
      queryParameters: filter.toQueryParameters(),
      parser: (json) => (json as List).map((e) => UserResponse.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<UserResponse> getById(int id) {
    return _client.get<UserResponse>(
      '$_path/$id',
      parser: (json) => UserResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<int> create(CreateUserRequest request) {
    return _client.post<int>(
      _path,
      body: request.toJson(),
      parser: (json) => json is Map<String, dynamic> ? json['id'] as int : json as int,
    );
  }

  Future<void> update(int id, UpdateUserRequest request) {
    return _client.put<void>(
      '$_path/$id',
      body: request.toJson(),
      parser: (_) {},
    );
  }

  Future<void> delete(int id) => _client.delete('$_path/$id');

  Future<UserResponse> uploadImage(int userId, String filePath) {
    return _client.uploadFile<UserResponse>(
      '$_path/$userId/image',
      filePath,
      'file',
      parser: (json) => UserResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> deleteImage(int userId) => _client.delete('$_path/$userId/image');
}
