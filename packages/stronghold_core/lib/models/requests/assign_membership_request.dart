/// Request to assign a membership to a user
class AssignMembershipRequest {
  final int userId;
  final int membershipPackageId;
  final double amountPaid;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime paymentDate;

  const AssignMembershipRequest({
    required this.userId,
    required this.membershipPackageId,
    required this.amountPaid,
    required this.startDate,
    required this.endDate,
    required this.paymentDate,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'membershipPackageId': membershipPackageId,
    'amountPaid': amountPaid,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'paymentDate': paymentDate.toIso8601String(),
  };
}
