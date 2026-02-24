/// Purchased supplement available for review
class PurchasedSupplementResponse {
  final int id;
  final String name;

  const PurchasedSupplementResponse({
    required this.id,
    required this.name,
  });

  factory PurchasedSupplementResponse.fromJson(Map<String, dynamic> json) {
    return PurchasedSupplementResponse(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
