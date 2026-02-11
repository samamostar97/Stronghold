import '../common/date_time_utils.dart';

/// User with active membership, returned by GET /api/memberships/active-members.
class ActiveMemberResponse {
  final int userId;
  final String firstName;
  final String lastName;
  final String username;
  final String? profileImageUrl;
  final String packageName;
  final DateTime membershipEndDate;

  const ActiveMemberResponse({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.profileImageUrl,
    required this.packageName,
    required this.membershipEndDate,
  });

  factory ActiveMemberResponse.fromJson(Map<String, dynamic> json) {
    return ActiveMemberResponse(
      userId: json['userId'] as int,
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      packageName: (json['packageName'] ?? '') as String,
      membershipEndDate: DateTimeUtils.parseApiDateTime(
        json['membershipEndDate'] as String,
      ),
    );
  }

  String get fullName => '$firstName $lastName';
}
