/// Matches backend UpdateSupplementRequest exactly
class UpdateSupplementRequest {
  final String name;
  final double price;
  final String? description;
  final int supplementCategoryId;
  final int supplierId;

  const UpdateSupplementRequest({
    required this.name,
    required this.price,
    this.description,
    required this.supplementCategoryId,
    required this.supplierId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'description': description,
        'supplementCategoryId': supplementCategoryId,
        'supplierId': supplierId,
      };
}
