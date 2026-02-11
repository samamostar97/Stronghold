import 'package:stronghold_core/stronghold_core.dart';

class Appointment {
  final int id;
  final String? trainerName;
  final String? nutritionistName;
  final DateTime appointmentDate;

  Appointment({
    required this.id,
    this.trainerName,
    this.nutritionistName,
    required this.appointmentDate,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as int,
      trainerName: json['trainerName'] as String?,
      nutritionistName: json['nutritionistName'] as String?,
      appointmentDate:
          AppointmentDateUtils.parse(json['appointmentDate'] as String),
    );
  }
}

class Trainer {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  Trainer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  String get fullName => '$firstName $lastName';

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }
}

class Nutritionist {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  Nutritionist({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  String get fullName => '$firstName $lastName';

  factory Nutritionist.fromJson(Map<String, dynamic> json) {
    return Nutritionist(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }
}
