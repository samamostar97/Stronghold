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
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  bool get isActive => DateTime.now().isBefore(endDate);
}
