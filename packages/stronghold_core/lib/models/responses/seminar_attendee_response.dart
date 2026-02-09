/// Matches backend SeminarAttendeeResponse
class SeminarAttendeeResponse {
  final int userId;
  final String userName;
  final DateTime registeredAt;

  const SeminarAttendeeResponse({
    required this.userId,
    required this.userName,
    required this.registeredAt,
  });

  factory SeminarAttendeeResponse.fromJson(Map<String, dynamic> json) {
    return SeminarAttendeeResponse(
      userId: (json['userId'] ?? 0) as int,
      userName: (json['userName'] ?? '') as String,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
    );
  }
}
