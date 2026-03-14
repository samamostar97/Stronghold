import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/membership_package_response.dart';

class MembershipPackagesRepository {
  final Dio _dio = ApiClient.instance;

  Future<PagedMembershipPackageResponse> getPackages({
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
      '/membership-packages',
      queryParameters: params,
    );
    return PagedMembershipPackageResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<MembershipPackageResponse> createPackage({
    required String name,
    String? description,
    required double price,
  }) async {
    final response = await _dio.post(
      '/membership-packages',
      data: {
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
        'price': price,
      },
    );
    return MembershipPackageResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<MembershipPackageResponse> updatePackage({
    required int id,
    required String name,
    String? description,
    required double price,
  }) async {
    final response = await _dio.put(
      '/membership-packages/$id',
      data: {
        'name': name,
        'description': description,
        'price': price,
      },
    );
    return MembershipPackageResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<void> deletePackage(int id) async {
    try {
      await _dio.delete('/membership-packages/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final membershipPackagesRepositoryProvider =
    Provider<MembershipPackagesRepository>((ref) {
  return MembershipPackagesRepository();
});
