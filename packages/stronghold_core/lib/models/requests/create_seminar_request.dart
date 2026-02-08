/// Matches backend CreateSeminarRequest exactly
class CreateSeminarRequest {
  final String topic;
  final String speakerName;
  final DateTime eventDate;

  const CreateSeminarRequest({
    required this.topic,
    required this.speakerName,
    required this.eventDate,
  });

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'speakerName': speakerName,
        'eventDate': eventDate.toIso8601String(),
      };
}
