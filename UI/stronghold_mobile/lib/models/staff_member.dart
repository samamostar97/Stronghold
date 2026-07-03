/// Trener ili nutricionista - polja koja mobile koristi za booking.
class StaffMember {
  final int id;
  final String firstName;
  final String lastName;
  final String staffType;
  final String biography;
  final int workStartHour;
  final int workEndHour;
  final bool hasImage;

  StaffMember({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.staffType,
    required this.biography,
    required this.workStartHour,
    required this.workEndHour,
    required this.hasImage,
  });

  String get fullName => '$firstName $lastName';
  String get typeLabel => staffType == 'Trainer' ? 'Trener' : 'Nutricionista';

  factory StaffMember.fromJson(Map<String, dynamic> json) => StaffMember(
        id: json['id'] as int,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        staffType: json['staffType'] as String,
        biography: json['biography'] as String,
        workStartHour: json['workStartHour'] as int,
        workEndHour: json['workEndHour'] as int,
        hasImage: json['hasImage'] as bool,
      );
}
