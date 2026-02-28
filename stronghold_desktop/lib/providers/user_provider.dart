import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import '../services/services.dart';
import 'api_providers.dart';
import 'list_notifier.dart';
import 'list_state.dart';

/// User service provider
final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(apiClientProvider));
});

/// User list state provider
final userListProvider = StateNotifierProvider<
    UserListNotifier,
    ListState<UserResponse, UserQueryFilter>>((ref) {
  final service = ref.watch(userServiceProvider);
  return UserListNotifier(service);
});

/// User list notifier implementation
class UserListNotifier extends ListNotifier<
    UserResponse,
    CreateUserRequest,
    UpdateUserRequest,
    UserQueryFilter> {
  final UserService _userService;

  UserListNotifier(UserService service)
      : _userService = service,
        super(
          getAll: service.getAll,
          create: service.create,
          update: service.update,
          delete: service.delete,
          initialFilter: UserQueryFilter(),
        );

  @override
  UserQueryFilter createFilterCopy({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    // Backend expects 'name' parameter, not 'search'
    // null = keep old value, '' = clear search, 'value' = new search
    final nameValue = search == null ? state.filter.name : (search.isEmpty ? null : search);
    return UserQueryFilter(
      pageNumber: pageNumber ?? state.filter.pageNumber,
      pageSize: pageSize ?? state.filter.pageSize,
      orderBy: orderBy ?? state.filter.orderBy,
      name: nameValue,
    );
  }

  /// Upload profile image for a user
  Future<UserResponse> uploadImage(int userId, String filePath) async {
    final result = await _userService.uploadImage(userId, filePath);
    await refresh();
    return result;
  }

  /// Delete profile image for a user
  Future<void> deleteImage(int userId) async {
    await _userService.deleteImage(userId);
    await refresh();
  }
}
