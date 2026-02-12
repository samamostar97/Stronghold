import '../common/date_time_utils.dart';

class AdminUpdateAppointmentRequest {
  final int? trainerId;
  final int? nutritionistId;
  final DateTime appointmentDate;

  const AdminUpdateAppointmentRequest({
    this.trainerId,
    this.nutritionistId,
    required this.appointmentDate,
  });

  Map<String, dynamic> toJson() => {
        if (trainerId != null) 'trainerId': trainerId,
        if (nutritionistId != null) 'nutritionistId': nutritionistId,
        'appointmentDate': DateTimeUtils.toApiDateTime(appointmentDate),
      };
}
