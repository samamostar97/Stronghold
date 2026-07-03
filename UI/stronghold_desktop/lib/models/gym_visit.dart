class GymVisit {
  final int id;
  final int userId;
  final String userFullName;
  final String username;
  final DateTime checkInAt;
  final DateTime? checkOutAt;
  final int durationMinutes;

  GymVisit({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.username,
    required this.checkInAt,
    this.checkOutAt,
    required this.durationMinutes,
  });

  factory GymVisit.fromJson(Map<String, dynamic> json) => GymVisit(
        id: json['id'] as int,
        userId: json['userId'] as int,
        userFullName: json['userFullName'] as String,
        username: json['username'] as String,
        checkInAt: DateTime.parse(json['checkInAt'] as String),
        checkOutAt: json['checkOutAt'] != null
            ? DateTime.parse(json['checkOutAt'] as String)
            : null,
        durationMinutes: json['durationMinutes'] as int,
      );
}
