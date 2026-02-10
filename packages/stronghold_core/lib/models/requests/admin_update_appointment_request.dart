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
        'appointmentDate': appointmentDate.toIso8601String(),
      };
}
