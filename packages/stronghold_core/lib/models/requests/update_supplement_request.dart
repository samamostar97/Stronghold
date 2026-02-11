/// Matches backend UpdateSupplementRequest exactly
class UpdateSupplementRequest {
  final String? name;
  final double? price;
  final String? description;
  final int? supplementCategoryId;
  final int? supplierId;

  const UpdateSupplementRequest({
    this.name,
    this.price,
    this.description,
    this.supplementCategoryId,
    this.supplierId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (price != null) map['price'] = price;
    if (description != null) map['description'] = description;
    if (supplementCategoryId != null) map['supplementCategoryId'] = supplementCategoryId;
    if (supplierId != null) map['supplierId'] = supplierId;
    return map;
  }
}
