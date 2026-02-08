/// Membership payment response from backend
class MembershipPaymentResponse {
  final int id;
  final int membershipPackageId;
  final String packageName;
  final double amountPaid;
  final DateTime paymentDate;
  final DateTime startDate;
  final DateTime endDate;

  const MembershipPaymentResponse({
    required this.id,
    required this.membershipPackageId,
    required this.packageName,
    required this.amountPaid,
    required this.paymentDate,
    required this.startDate,
    required this.endDate,
  });

  factory MembershipPaymentResponse.fromJson(Map<String, dynamic> json) {
    return MembershipPaymentResponse(
      id: json['id'] as int,
      membershipPackageId: json['membershipPackageId'] as int,
      packageName: json['packageName'] as String,
      amountPaid: (json['amountPaid'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }
}
