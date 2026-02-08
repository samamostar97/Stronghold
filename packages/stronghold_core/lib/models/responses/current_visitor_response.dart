/// Response for a visitor currently in the gym
class CurrentVisitorResponse {
  final int visitId;
  final int userId;
  final String username;
  final String firstName;
  final String lastName;
  final DateTime checkInTime;

  const CurrentVisitorResponse({
    required this.visitId,
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.checkInTime,
  });

  factory CurrentVisitorResponse.fromJson(Map<String, dynamic> json) {
    // Parse the checkInTime - ALWAYS treat as UTC (backend sends UTC time with or without Z)
    final checkInTimeString = json['checkInTime'] ?? DateTime.now().toIso8601String();

    // Force UTC parsing by adding Z if not present, then convert to local
    final normalizedString = checkInTimeString.endsWith('Z')
        ? checkInTimeString
        : '${checkInTimeString}Z';

    final parsedTime = DateTime.tryParse(normalizedString)?.toLocal() ?? DateTime.now();

    return CurrentVisitorResponse(
      visitId: (json['visitId'] ?? json['gymVisitId'] ?? json['id'] ?? 0) as int,
      userId: (json['userId'] ?? 0) as int,
      username: (json['username'] ?? '') as String,
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      checkInTime: parsedTime,
    );
  }

  /// Convenience getter for full name display
  String get fullName => '$firstName $lastName';

  /// Formats check-in time as HH:mm for display in table
  String get checkInTimeFormatted {
    return '${checkInTime.hour.toString().padLeft(2, '0')}:'
        '${checkInTime.minute.toString().padLeft(2, '0')}';
  }

  /// Calculates and formats the duration since check-in
  String get durationFormatted {
    final now = DateTime.now();
    final difference = now.difference(checkInTime);

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
