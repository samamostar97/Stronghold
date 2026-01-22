class SupplierDTO {
  final int id;
  final String name;
  final String? website;


  const SupplierDTO({
    required this.id,
    required this.name,
    this.website

  });

  factory SupplierDTO.fromJson(Map<String, dynamic> json) {
    return SupplierDTO(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      website:(json['website'] as String?)
    );
  }
}
class CreateSupplierDTO {
  final String name;
  final String? website;



  const CreateSupplierDTO({
    required this.name,
    this.website,

  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'website' : website,
      };
}

class UpdateSupplierDTO {
  final String? name;
  final String? website;


  const UpdateSupplierDTO({
    this.name,
    this.website,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (website != null) map['website'] = website;

    return map;
  }
}

class PagedSuppliersResult {
  final List<SupplierDTO> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const PagedSuppliersResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PagedSuppliersResult.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => SupplierDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <SupplierDTO>[];

    return PagedSuppliersResult(
      items: itemsList,
      totalCount: (json['totalCount'] ?? 0) as int,
      pageNumber: (json['pageNumber'] ?? 1) as int,
      pageSize: (json['pageSize'] ?? 10) as int,
      totalPages: (json['totalPages'] ?? 1) as int,
    );
  }
}
