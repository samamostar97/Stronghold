import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment_response.freezed.dart';
part 'appointment_response.g.dart';

@freezed
abstract class AppointmentResponse with _$AppointmentResponse {
  const factory AppointmentResponse({
    required int id,
    required int userId,
    required String userName,
    required int staffId,
    required String staffName,
    required String staffType,
    required DateTime scheduledAt,
    required int durationMinutes,
    required String status,
    String? notes,
    required DateTime createdAt,
  }) = _AppointmentResponse;

  factory AppointmentResponse.fromJson(Map<String, dynamic> json) =>
      _$AppointmentResponseFromJson(json);
}

@freezed
abstract class PagedAppointmentResponse with _$PagedAppointmentResponse {
  const factory PagedAppointmentResponse({
    required List<AppointmentResponse> items,
    required int totalCount,
    required int totalPages,
    required int currentPage,
    required int pageSize,
  }) = _PagedAppointmentResponse;

  factory PagedAppointmentResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedAppointmentResponseFromJson(json);
}
