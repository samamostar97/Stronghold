import '../common/date_time_utils.dart';

/// Matches backend SeminarResponse
class SeminarResponse {
  final int id;
  final String topic;
  final String speakerName;
  final DateTime eventDate;
  final int maxCapacity;
  final int currentAttendees;
  final bool isCancelled;
  final String status;

  const SeminarResponse({
    required this.id,
    required this.topic,
    required this.speakerName,
    required this.eventDate,
    required this.maxCapacity,
    required this.currentAttendees,
    required this.isCancelled,
    required this.status,
  });

  factory SeminarResponse.fromJson(Map<String, dynamic> json) {
    return SeminarResponse(
      id: (json['id'] ?? 0) as int,
      topic: (json['topic'] ?? '') as String,
      speakerName: (json['speakerName'] ?? '') as String,
      eventDate: DateTimeUtils.parseApiDateTime(json['eventDate'] as String),
      maxCapacity: (json['maxCapacity'] ?? 0) as int,
      currentAttendees: (json['currentAttendees'] ?? 0) as int,
      isCancelled: (json['isCancelled'] ?? false) as bool,
      status: (json['status'] ?? 'active') as String,
    );
  }
}
