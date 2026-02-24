import '../common/date_time_utils.dart';

/// User-facing appointment response (member's own appointments)
class UserAppointmentResponse {
  final int id;
  final String? trainerName;
  final String? nutritionistName;
  final DateTime appointmentDate;

  const UserAppointmentResponse({
    required this.id,
    this.trainerName,
    this.nutritionistName,
    required this.appointmentDate,
  });

  factory UserAppointmentResponse.fromJson(Map<String, dynamic> json) {
    return UserAppointmentResponse(
      id: json['id'] as int,
      trainerName: json['trainerName'] as String?,
      nutritionistName: json['nutritionistName'] as String?,
      appointmentDate:
          DateTimeUtils.parseApiDateTime(json['appointmentDate'] as String),
    );
  }
}
