import '../common/date_time_utils.dart';

class AdminMembershipPaymentResponse {
  final int id;
  final int userId;
  final String userName;
  final String userEmail;
  final int membershipPackageId;
  final String packageName;
  final num amountPaid;
  final DateTime paymentDate;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const AdminMembershipPaymentResponse({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.membershipPackageId,
    required this.packageName,
    required this.amountPaid,
    required this.paymentDate,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory AdminMembershipPaymentResponse.fromJson(Map<String, dynamic> json) {
    return AdminMembershipPaymentResponse(
      id: (json['id'] ?? 0) as int,
      userId: (json['userId'] ?? 0) as int,
      userName: (json['userName'] ?? '') as String,
      userEmail: (json['userEmail'] ?? '') as String,
      membershipPackageId: (json['membershipPackageId'] ?? 0) as int,
      packageName: (json['packageName'] ?? '') as String,
      amountPaid: (json['amountPaid'] ?? 0) as num,
      paymentDate: DateTimeUtils.parseApiDateTime(
        json['paymentDate'] as String,
      ),
      startDate: DateTimeUtils.parseApiDateTime(
        json['startDate'] as String,
      ),
      endDate: DateTimeUtils.parseApiDateTime(
        json['endDate'] as String,
      ),
      isActive: (json['isActive'] ?? false) as bool,
    );
  }
}
