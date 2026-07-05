class Seminar {
  final int id;
  final String topic;
  final String speaker;
  final DateTime scheduledAt;
  final int maxCapacity;
  final int registeredCount;

  Seminar({
    required this.id,
    required this.topic,
    required this.speaker,
    required this.scheduledAt,
    required this.maxCapacity,
    required this.registeredCount,
  });

  factory Seminar.fromJson(Map<String, dynamic> json) => Seminar(
        id: json['id'] as int,
        topic: json['topic'] as String,
        speaker: json['speaker'] as String,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        maxCapacity: json['maxCapacity'] as int,
        registeredCount: json['registeredCount'] as int,
      );
}

class SeminarRegistration {
  final String userFullName;
  final String username;
  final DateTime registeredAt;

  SeminarRegistration({
    required this.userFullName,
    required this.username,
    required this.registeredAt,
  });

  factory SeminarRegistration.fromJson(Map<String, dynamic> json) =>
      SeminarRegistration(
        userFullName: json['userFullName'] as String,
        username: json['username'] as String,
        registeredAt: DateTime.parse(json['registeredAt'] as String),
      );
}
