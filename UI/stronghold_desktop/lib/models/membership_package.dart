class MembershipPackage {
  final int id;
  final String name;
  final double price;
  final int durationDays;
  final String description;

  MembershipPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.description,
  });

  factory MembershipPackage.fromJson(Map<String, dynamic> json) => MembershipPackage(
        id: json['id'] as int,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        durationDays: json['durationDays'] as int,
        description: json['description'] as String,
      );
}
