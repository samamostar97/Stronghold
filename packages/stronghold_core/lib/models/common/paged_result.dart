/// Generic paged result matching backend PagedResult<T>.
/// Note: Backend returns items, totalCount, pageNumber.
/// pageSize comes from the QueryFilter sent to API.
class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int pageNumber;

  const PagedResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
  });

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map<T>((e) => itemParser(e as Map<String, dynamic>))
            .toList() ??
        <T>[];

    return PagedResult(
      items: itemsList,
      totalCount: (json['totalCount'] ?? 0) as int,
      pageNumber: (json['pageNumber'] ?? 1) as int,
    );
  }

  /// Calculate total pages based on pageSize from filter
  int totalPages(int pageSize) {
    if (totalCount == 0 || pageSize == 0) return 1;
    return (totalCount / pageSize).ceil();
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  bool hasNextPage(int pageSize) => pageNumber < totalPages(pageSize);
  bool get hasPreviousPage => pageNumber > 1;
}
