/// Matches backend SeminarResponse
class SeminarResponse {
  final int id;
  final String topic;
  final String speakerName;
  final DateTime eventDate;

  const SeminarResponse({
    required this.id,
    required this.topic,
    required this.speakerName,
    required this.eventDate,
  });

  factory SeminarResponse.fromJson(Map<String, dynamic> json) {
    return SeminarResponse(
      id: (json['id'] ?? 0) as int,
      topic: (json['topic'] ?? '') as String,
      speakerName: (json['speakerName'] ?? '') as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
    );
  }
}
