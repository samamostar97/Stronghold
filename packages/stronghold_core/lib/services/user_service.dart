import '../api/api_client.dart';
import 'crud_service.dart';
import '../models/responses/user_response.dart';
import '../models/requests/create_user_request.dart';
import '../models/requests/update_user_request.dart';
import '../models/filters/user_query_filter.dart';

/// User service using new generic CRUD pattern
/// Replaces old users_api.dart with 100+ LOC
class UserService extends CrudService<
    UserResponse,
    CreateUserRequest,
    UpdateUserRequest,
    UserQueryFilter> {
  final ApiClient _apiClient;
  static const String _path = '/api/users';

  UserService(ApiClient client)
      : _apiClient = client,
        super(
          client: client,
          basePath: _path,
          responseParser: UserResponse.fromJson,
        );

  @override
  Map<String, dynamic> toCreateJson(CreateUserRequest request) =>
      request.toJson();

  @override
  Map<String, dynamic> toUpdateJson(UpdateUserRequest request) =>
      request.toJson();

  /// Upload profile image for a user
  Future<UserResponse> uploadImage(int userId, String filePath) async {
    return _apiClient.uploadFile<UserResponse>(
      '$_path/$userId/image',
      filePath,
      'file',
      parser: (json) => UserResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Delete profile image for a user
  Future<void> deleteImage(int userId) async {
    await _apiClient.delete('$_path/$userId/image');
  }
}
