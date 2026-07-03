/// Termin clana - polja koja mobile prikazuje.
class Appointment {
  final int id;
  final String staffFullName;
  final String staffType;
  final DateTime date;
  final int startHour;
  final String status;
  final String? cancellationReason;

  Appointment({
    required this.id,
    required this.staffFullName,
    required this.staffType,
    required this.date,
    required this.startHour,
    required this.status,
    this.cancellationReason,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] as int,
        staffFullName: json['staffFullName'] as String,
        staffType: json['staffType'] as String,
        date: DateTime.parse(json['date'] as String),
        startHour: json['startHour'] as int,
        status: json['status'] as String,
        cancellationReason: json['cancellationReason'] as String?,
      );
}
