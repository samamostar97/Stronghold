class AdminCreateAppointmentRequest {
  final int userId;
  final int? trainerId;
  final int? nutritionistId;
  final DateTime appointmentDate;

  const AdminCreateAppointmentRequest({
    required this.userId,
    this.trainerId,
    this.nutritionistId,
    required this.appointmentDate,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        if (trainerId != null) 'trainerId': trainerId,
        if (nutritionistId != null) 'nutritionistId': nutritionistId,
        'appointmentDate': appointmentDate.toIso8601String(),
      };
}
