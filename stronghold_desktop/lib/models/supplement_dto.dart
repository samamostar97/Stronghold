class SupplementDTO {
  final int id;
  final String name;
  final double price;
  final String? description;
  final int supplementCategoryId;
  final int supplierId;

  const SupplementDTO({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.supplementCategoryId,
    required this.supplierId,
  });

  factory SupplementDTO.fromJson(Map<String, dynamic> json) {
    return SupplementDTO(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      price: ((json['price'] ?? 0) as num).toDouble(),
      description: json['description'] as String?,
      supplementCategoryId: (json['supplementCategoryId'] ?? 0) as int,
      supplierId: (json['supplierId'] ?? 0) as int,
    );
  }
}

class CreateSupplementDTO {
  final String name;
  final double price;
  final String? description;
  final int supplementCategoryId;
  final int supplierId;

  const CreateSupplementDTO({
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

class UpdateSupplementDTO {
  final String? name;
  final double? price;
  final String? description;

  const UpdateSupplementDTO({
    this.name,
    this.price,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (price != null) map['price'] = price;
    if (description != null) map['description'] = description;
    return map;
  }
}
