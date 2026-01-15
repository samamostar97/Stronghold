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
