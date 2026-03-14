import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/eligible_member_response.dart';
import '../models/gym_visit_response.dart';

class GymRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<EligibleMemberResponse>> getEligibleForCheckIn({
    String? search,
  }) async {
    final params = <String, dynamic>{
      'pageSize': 100,
    };
    if (search != null && search.isNotEmpty) params['search'] = search;

    final response = await _dio.get(
      '/gym-visits/eligible-members',
      queryParameters: params,
    );
    final data = response.data as Map<String, dynamic>;
    return (data['items'] as List)
        .map((e) => EligibleMemberResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<GymVisitResponse>> getActiveVisits() async {
    final response = await _dio.get('/gym-visits/active');
    final list = response.data as List;
    return list
        .map((e) => GymVisitResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PagedGymVisitResponse> getVisitHistory({
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
  }) async {
    final params = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'orderDescending': true,
    };
    if (search != null && search.isNotEmpty) params['search'] = search;

    final response = await _dio.get(
      '/gym-visits',
      queryParameters: params,
    );
    return PagedGymVisitResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<GymVisitResponse> checkIn({required int userId}) async {
    try {
      final response = await _dio.post(
        '/gym-visits/check-in',
        data: {'userId': userId},
      );
      return GymVisitResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<GymVisitResponse> checkOut({required int visitId}) async {
    final response = await _dio.post('/gym-visits/$visitId/check-out');
    return GymVisitResponse.fromJson(
        response.data as Map<String, dynamic>);
  }
}

final gymRepositoryProvider = Provider<GymRepository>((ref) {
  return GymRepository();
});
