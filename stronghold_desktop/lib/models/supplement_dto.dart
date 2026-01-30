class SupplementDTO {
  final int id;
  final String name;
  final double price;
  final String? description;
  final int supplementCategoryId;
  final int supplierId;
  final String? supplementCategoryName;
  final String? supplierName;
  final String? supplementImageUrl;

  const SupplementDTO({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.supplementCategoryId,
    required this.supplierId,
    this.supplementCategoryName,
    this.supplierName,
    this.supplementImageUrl,
  });

  factory SupplementDTO.fromJson(Map<String, dynamic> json) {
    return SupplementDTO(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      price: ((json['price'] ?? 0) as num).toDouble(),
      description: json['description'] as String?,
      supplementCategoryId: (json['supplementCategoryId'] ?? 0) as int,
      supplierId: (json['supplierId'] ?? 0) as int,
      supplementCategoryName: json['supplementCategoryName'] as String?,
      supplierName: json['supplierName'] as String?,
      supplementImageUrl: json['supplementImageUrl'] as String?,
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

class PagedSupplementsResult {
  final List<SupplementDTO> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const PagedSupplementsResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PagedSupplementsResult.fromJson(Map<String, dynamic> json, int pageSize) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => SupplementDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <SupplementDTO>[];

    final totalCount = (json['totalCount'] ?? 0) as int;
    final totalPages = totalCount > 0 ? ((totalCount / pageSize).ceil()) : 1;

    return PagedSupplementsResult(
      items: itemsList,
      totalCount: totalCount,
      pageNumber: (json['pageNumber'] ?? 1) as int,
      pageSize: pageSize,
      totalPages: totalPages,
    );
  }
}
