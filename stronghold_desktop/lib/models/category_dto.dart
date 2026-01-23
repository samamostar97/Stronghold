class CategoryDTO {
  final int id;
  final String name;


  const CategoryDTO({
    required this.id,
    required this.name,
  });

  factory CategoryDTO.fromJson(Map<String, dynamic> json) {
    return CategoryDTO(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
    );
  }
}

class CreateCategoryDTO {
  final String name;


  const CreateCategoryDTO({
    required this.name,

  });

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}

class UpdateCategoryDTO {
  final String? name;

  const UpdateCategoryDTO({
    this.name,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    return map;
  }
}

class PagedCategoriesResult {
  final List<CategoryDTO> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const PagedCategoriesResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PagedCategoriesResult.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => CategoryDTO.fromJson(e as Map<String, dynamic>))
            .toList() ??
        <CategoryDTO>[];

    return PagedCategoriesResult(
      items: itemsList,
      totalCount: (json['totalCount'] ?? 0) as int,
      pageNumber: (json['pageNumber'] ?? 1) as int,
      pageSize: (json['pageSize'] ?? 10) as int,
      totalPages: (json['totalPages'] ?? 1) as int,
    );
  }
}
