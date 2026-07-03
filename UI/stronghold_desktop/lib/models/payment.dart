class Payment {
  final int id;
  final int userId;
  final String userFullName;
  final String packageName;
  final double amount;
  final DateTime paidAt;

  Payment({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.packageName,
    required this.amount,
    required this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] as int,
        userId: json['userId'] as int,
        userFullName: json['userFullName'] as String,
        packageName: json['packageName'] as String,
        amount: (json['amount'] as num).toDouble(),
        paidAt: DateTime.parse(json['paidAt'] as String),
      );
}
