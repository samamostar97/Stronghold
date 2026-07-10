class Seminar {
  final int id;
  final String topic;
  final String speaker;
  final DateTime scheduledAt;
  final int maxCapacity;
  final int remainingCapacity;
  final bool isCancelled;
  final String? cancellationReason;
  final bool isCurrentUserRegistered;

  Seminar({
    required this.id,
    required this.topic,
    required this.speaker,
    required this.scheduledAt,
    required this.maxCapacity,
    required this.remainingCapacity,
    required this.isCancelled,
    this.cancellationReason,
    required this.isCurrentUserRegistered,
  });

  factory Seminar.fromJson(Map<String, dynamic> json) => Seminar(
        id: json['id'] as int,
        topic: json['topic'] as String,
        speaker: json['speaker'] as String,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        maxCapacity: json['maxCapacity'] as int,
        remainingCapacity: json['remainingCapacity'] as int,
        isCancelled: json['isCancelled'] as bool,
        cancellationReason: json['cancellationReason'] as String?,
        isCurrentUserRegistered: json['isCurrentUserRegistered'] as bool,
      );
}
