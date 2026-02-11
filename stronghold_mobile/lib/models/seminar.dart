import 'package:stronghold_core/stronghold_core.dart';

class Seminar {
  final int id;
  final String topic;
  final String speakerName;
  final DateTime eventDate;
  final bool isAttending;
  final int maxCapacity;
  final int currentAttendees;

  Seminar({
    required this.id,
    required this.topic,
    required this.speakerName,
    required this.eventDate,
    required this.isAttending,
    required this.maxCapacity,
    required this.currentAttendees,
  });

  bool get isFull => currentAttendees >= maxCapacity;

  factory Seminar.fromJson(Map<String, dynamic> json) {
    return Seminar(
      id: json['id'] as int,
      topic: json['topic'] as String,
      speakerName: json['speakerName'] as String,
      eventDate: DateTimeUtils.parseApiDateTime(json['eventDate'] as String),
      isAttending: json['isAttending'] as bool? ?? false,
      maxCapacity: json['maxCapacity'] as int? ?? 0,
      currentAttendees: json['currentAttendees'] as int? ?? 0,
    );
  }
}
