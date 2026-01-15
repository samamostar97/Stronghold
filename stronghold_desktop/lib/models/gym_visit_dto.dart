/// Data Transfer Object for a visitor currently in the gym.
/// Maps to the backend's CurrentVisitorDTO response.
class CurrentVisitorDTO {
  final int visitId;
  final int userId;
  final String username;
  final String firstName;
  final String lastName;
  final DateTime checkInTime;
  final String duration;

  CurrentVisitorDTO({
    required this.visitId,
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.checkInTime,
    required this.duration,
  });

  /// Creates a CurrentVisitorDTO from JSON response.
  /// Uses defensive parsing with null checks and defaults.
  factory CurrentVisitorDTO.fromJson(Map<String, dynamic> json) {
    return CurrentVisitorDTO(
      // Backend may return 'visitId' or 'gymVisitId' depending on endpoint
      visitId: (json['visitId'] ?? json['gymVisitId'] ?? 0) as int,
      userId: (json['userId'] ?? 0) as int,
      username: (json['username'] ?? '') as String,
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      checkInTime: DateTime.parse(
        json['checkInTime'] ?? DateTime.now().toIso8601String(),
      ),
      duration: (json['duration'] ?? '0m') as String,
    );
  }

  /// Convenience getter for full name display
  String get fullName => '$firstName $lastName';

  /// Formats check-in time as HH:mm for display in table
  String get checkInTimeFormatted {
    return '${checkInTime.hour.toString().padLeft(2, '0')}:'
        '${checkInTime.minute.toString().padLeft(2, '0')}';
  }
}
