import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/user_membership_response.dart';

class MembershipsRepository {
  final Dio _dio = ApiClient.instance;

  Future<PagedUserMembershipResponse> getActiveMemberships({
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
  }) async {
    final params = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };
    if (search != null && search.isNotEmpty) params['search'] = search;

    final response = await _dio.get(
      '/memberships/active',
      queryParameters: params,
    );
    return PagedUserMembershipResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<PagedUserMembershipResponse> getMembershipHistory({
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
    String? status, // "Expired" or "Cancelled"
  }) async {
    final params = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (status != null && status.isNotEmpty) params['status'] = status;

    final response = await _dio.get(
      '/memberships/history',
      queryParameters: params,
    );
    return PagedUserMembershipResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<UserMembershipResponse> assignMembership({
    required int userId,
    required int membershipPackageId,
  }) async {
    try {
      final response = await _dio.post(
        '/users/$userId/membership',
        data: {'membershipPackageId': membershipPackageId},
      );
      return UserMembershipResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> cancelMembership({required int userId}) async {
    try {
      await _dio.delete('/users/$userId/membership');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final membershipsRepositoryProvider = Provider<MembershipsRepository>((ref) {
  return MembershipsRepository();
});
