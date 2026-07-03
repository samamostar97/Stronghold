/// Standardni oblik paginiranih odgovora API-ja.
class PagedResult<T> {
  final List<T> items;
  final int totalCount;

  PagedResult({required this.items, required this.totalCount});

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) =>
      PagedResult(
        items: (json['items'] as List)
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList(),
        totalCount: json['totalCount'] as int,
      );
}
