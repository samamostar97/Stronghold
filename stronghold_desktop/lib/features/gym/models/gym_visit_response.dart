import 'package:freezed_annotation/freezed_annotation.dart';

part 'gym_visit_response.freezed.dart';
part 'gym_visit_response.g.dart';

@freezed
abstract class GymVisitResponse with _$GymVisitResponse {
  const factory GymVisitResponse({
    required int id,
    required int userId,
    required String userFullName,
    required String username,
    required DateTime checkInAt,
    DateTime? checkOutAt,
    int? durationMinutes,
  }) = _GymVisitResponse;

  factory GymVisitResponse.fromJson(Map<String, dynamic> json) =>
      _$GymVisitResponseFromJson(json);
}

@freezed
abstract class PagedGymVisitResponse with _$PagedGymVisitResponse {
  const factory PagedGymVisitResponse({
    required List<GymVisitResponse> items,
    required int totalCount,
    required int totalPages,
    required int currentPage,
    required int pageSize,
  }) = _PagedGymVisitResponse;

  factory PagedGymVisitResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedGymVisitResponseFromJson(json);
}
