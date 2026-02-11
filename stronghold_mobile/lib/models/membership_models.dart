import 'package:stronghold_core/stronghold_core.dart';

class MembershipPayment {
  final int id;
  final String packageName;
  final double amountPaid;
  final DateTime paymentDate;
  final DateTime startDate;
  final DateTime endDate;

  MembershipPayment({
    required this.id,
    required this.packageName,
    required this.amountPaid,
    required this.paymentDate,
    required this.startDate,
    required this.endDate,
  });

  factory MembershipPayment.fromJson(Map<String, dynamic> json) {
    return MembershipPayment(
      id: json['id'] as int,
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
