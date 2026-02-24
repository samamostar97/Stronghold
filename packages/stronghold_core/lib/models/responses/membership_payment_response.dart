import '../common/date_time_utils.dart';

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
      paymentDate: DateTimeUtils.parseApiDateTime(
        json['paymentDate'] as String,
      ),
      startDate: DateTimeUtils.parseApiDateTime(json['startDate'] as String),
      endDate: DateTimeUtils.parseApiDateTime(json['endDate'] as String),
    );
  }

  bool get isActive => DateTime.now().isBefore(endDate);
}
