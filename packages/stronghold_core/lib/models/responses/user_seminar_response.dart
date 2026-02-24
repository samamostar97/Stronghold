import '../common/date_time_utils.dart';

/// User-facing seminar response (upcoming seminars for members)
class UserSeminarResponse {
  final int id;
  final String topic;
  final String speakerName;
  final DateTime eventDate;
  final bool isAttending;
  final bool isCancelled;
  final String status;
  final int maxCapacity;
  final int currentAttendees;

  const UserSeminarResponse({
    required this.id,
    required this.topic,
    required this.speakerName,
    required this.eventDate,
    required this.isAttending,
    required this.isCancelled,
    required this.status,
    required this.maxCapacity,
    required this.currentAttendees,
  });

  bool get isFull => currentAttendees >= maxCapacity;

  factory UserSeminarResponse.fromJson(Map<String, dynamic> json) {
    return UserSeminarResponse(
      id: json['id'] as int,
      topic: json['topic'] as String,
      speakerName: json['speakerName'] as String,
      eventDate: DateTimeUtils.parseApiDateTime(json['eventDate'] as String),
      isAttending: json['isAttending'] as bool? ?? false,
      isCancelled: json['isCancelled'] as bool? ?? false,
      status: json['status'] as String? ?? 'active',
      maxCapacity: json['maxCapacity'] as int? ?? 0,
      currentAttendees: json['currentAttendees'] as int? ?? 0,
    );
  }
}
