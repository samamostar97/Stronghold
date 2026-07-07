class Membership {
  final int id;
  final int userId;
  final String userFullName;
  final String username;
  final int packageId;
  final String packageName;
  final DateTime startDate;
  final DateTime endDate;
  final bool isRevoked;
  final String? revocationReason;
  final bool isActive;
  final bool isUpcoming;

  Membership({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.username,
    required this.packageId,
    required this.packageName,
    required this.startDate,
    required this.endDate,
    required this.isRevoked,
    this.revocationReason,
    required this.isActive,
    required this.isUpcoming,
  });

  factory Membership.fromJson(Map<String, dynamic> json) => Membership(
        id: json['id'] as int,
        userId: json['userId'] as int,
        userFullName: json['userFullName'] as String,
        username: json['username'] as String,
        packageId: json['packageId'] as int,
        packageName: json['packageName'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        isRevoked: json['isRevoked'] as bool,
        revocationReason: json['revocationReason'] as String?,
        isActive: json['isActive'] as bool,
        isUpcoming: json['isUpcoming'] as bool,
      );
}

/// Aktivna clanarina clana - upozorenje pri evidenciji nove uplate.
class ActiveMembershipInfo {
  final bool hasActive;
  final String? packageName;
  final DateTime? endDate;

  ActiveMembershipInfo({
    required this.hasActive,
    this.packageName,
    this.endDate,
  });

  factory ActiveMembershipInfo.fromJson(Map<String, dynamic> json) =>
      ActiveMembershipInfo(
        hasActive: json['hasActive'] as bool,
        packageName: json['packageName'] as String?,
        endDate: json['endDate'] == null
            ? null
            : DateTime.parse(json['endDate'] as String),
      );
}
