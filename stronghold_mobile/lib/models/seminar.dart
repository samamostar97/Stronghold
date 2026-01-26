class Seminar {
  final int id;
  final String topic;
  final String speakerName;
  final DateTime eventDate;
  final bool isAttending;

  Seminar({
    required this.id,
    required this.topic,
    required this.speakerName,
    required this.eventDate,
    required this.isAttending,
  });

  factory Seminar.fromJson(Map<String, dynamic> json) {
    return Seminar(
      id: json['id'] as int,
      topic: json['topic'] as String,
      speakerName: json['speakerName'] as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
      isAttending: json['isAttending'] as bool? ?? false,
    );
  }
}
