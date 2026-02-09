/// Matches backend CreateSeminarRequest exactly
class CreateSeminarRequest {
  final String topic;
  final String speakerName;
  final DateTime eventDate;
  final int maxCapacity;

  const CreateSeminarRequest({
    required this.topic,
    required this.speakerName,
    required this.eventDate,
    required this.maxCapacity,
  });

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'speakerName': speakerName,
        'eventDate': eventDate.toIso8601String(),
        'maxCapacity': maxCapacity,
      };
}
