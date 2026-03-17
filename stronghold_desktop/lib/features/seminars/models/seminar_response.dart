import 'package:freezed_annotation/freezed_annotation.dart';

part 'seminar_response.freezed.dart';
part 'seminar_response.g.dart';

@freezed
abstract class SeminarResponse with _$SeminarResponse {
  const factory SeminarResponse({
    required int id,
    required String name,
    required String description,
    required String lecturer,
    required DateTime startDate,
    required int durationMinutes,
    required int maxCapacity,
    required int registeredCount,
    required DateTime createdAt,
  }) = _SeminarResponse;

  factory SeminarResponse.fromJson(Map<String, dynamic> json) =>
      _$SeminarResponseFromJson(json);
}

@freezed
abstract class PagedSeminarResponse with _$PagedSeminarResponse {
  const factory PagedSeminarResponse({
    required List<SeminarResponse> items,
    required int totalCount,
    required int totalPages,
    required int currentPage,
    required int pageSize,
  }) = _PagedSeminarResponse;

  factory PagedSeminarResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedSeminarResponseFromJson(json);
}

@freezed
abstract class SeminarRegistrationResponse with _$SeminarRegistrationResponse {
  const factory SeminarRegistrationResponse({
    required int id,
    required int userId,
    required String userFullName,
    required String userEmail,
    required DateTime createdAt,
  }) = _SeminarRegistrationResponse;

  factory SeminarRegistrationResponse.fromJson(Map<String, dynamic> json) =>
      _$SeminarRegistrationResponseFromJson(json);
}
