class Appointment {
  final int id;
  final int userId;
  final String userFullName;
  final int staffMemberId;
  final String staffFullName;
  final String staffType;
  final DateTime date;
  final int startHour;
  final String status;
  final String? cancelledBy;
  final String? cancellationReason;

  Appointment({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.staffMemberId,
    required this.staffFullName,
    required this.staffType,
    required this.date,
    required this.startHour,
    required this.status,
    this.cancelledBy,
    this.cancellationReason,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] as int,
        userId: json['userId'] as int,
        userFullName: json['userFullName'] as String,
        staffMemberId: json['staffMemberId'] as int,
        staffFullName: json['staffFullName'] as String,
        staffType: json['staffType'] as String,
        date: DateTime.parse(json['date'] as String),
        startHour: json['startHour'] as int,
        status: json['status'] as String,
        cancelledBy: json['cancelledBy'] as String?,
        cancellationReason: json['cancellationReason'] as String?,
      );
}
