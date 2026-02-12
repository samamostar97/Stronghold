import '../common/date_time_utils.dart';

/// Matches backend AdminAppointmentResponse
class AdminAppointmentResponse {
  final int id;
  final int userId;
  final int? trainerId;
  final int? nutritionistId;
  final String userName;
  final String? trainerName;
  final String? nutritionistName;
  final DateTime appointmentDate;
  final String type;

  const AdminAppointmentResponse({
    required this.id,
    required this.userId,
    this.trainerId,
    this.nutritionistId,
    required this.userName,
    this.trainerName,
    this.nutritionistName,
    required this.appointmentDate,
    required this.type,
  });

  factory AdminAppointmentResponse.fromJson(Map<String, dynamic> json) {
    return AdminAppointmentResponse(
      id: (json['id'] ?? 0) as int,
      userId: (json['userId'] ?? 0) as int,
      trainerId: json['trainerId'] as int?,
      nutritionistId: json['nutritionistId'] as int?,
      userName: (json['userName'] ?? '') as String,
      trainerName: json['trainerName'] as String?,
      nutritionistName: json['nutritionistName'] as String?,
      appointmentDate:
          DateTimeUtils.parseApiDateTime(json['appointmentDate'] as String),
      type: (json['type'] ?? '') as String,
    );
  }
}
