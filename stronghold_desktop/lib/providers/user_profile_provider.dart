import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stronghold_core/stronghold_core.dart';
import 'api_providers.dart';

/// Fetch a single user by ID
final userByIdProvider =
    FutureProvider.family<UserResponse, int>((ref, userId) async {
  final client = ref.watch(apiClientProvider);
  final service = UserService(client);
  return service.getById(userId);
});

/// Fetch user's address
final userAddressProvider =
    FutureProvider.family<AddressResponse?, int>((ref, userId) async {
  final client = ref.watch(apiClientProvider);
  final service = AddressService(client);
  try {
    return await service.getByUserId(userId);
  } catch (_) {
    return null;
  }
});

/// Fetch orders for a specific user (paginated)
final userOrdersProvider = FutureProvider.family<
    PagedResult<OrderResponse>, UserOrdersParams>((ref, params) async {
  final client = ref.watch(apiClientProvider);
  final service = OrderService(client);
  final filter = OrderQueryFilter(
    userId: params.userId,
    pageNumber: params.pageNumber,
    pageSize: params.pageSize,
  );
  return service.getAll(filter);
});

class UserOrdersParams {
  final int userId;
  final int pageNumber;
  final int pageSize;

  const UserOrdersParams({
    required this.userId,
    this.pageNumber = 1,
    this.pageSize = 10,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserOrdersParams &&
          userId == other.userId &&
          pageNumber == other.pageNumber &&
          pageSize == other.pageSize;

  @override
  int get hashCode =>
      userId.hashCode ^ pageNumber.hashCode ^ pageSize.hashCode;
}
