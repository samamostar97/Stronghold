/// Matches backend CreateSupplementRequest exactly
class CreateSupplementRequest {
  final String name;
  final double price;
  final String? description;
  final int supplementCategoryId;
  final int supplierId;

  const CreateSupplementRequest({
    required this.name,
    required this.price,
    this.description,
    required this.supplementCategoryId,
    required this.supplierId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        if (description != null) 'description': description,
        'supplementCategoryId': supplementCategoryId,
        'supplierId': supplierId,
      };
}
