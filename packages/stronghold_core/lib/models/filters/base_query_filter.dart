/// Base filter matching backend PaginationRequest.
/// All entity-specific filters extend this class.
abstract class BaseQueryFilter {
  int pageNumber;
  int pageSize;
  String? search;
  String? orderBy;

  BaseQueryFilter({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.search,
    this.orderBy,
  });

  /// Convert to query parameters for API call
  Map<String, String> toQueryParameters() {
    return {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      if (search != null && search!.isNotEmpty) 'search': search!,
      if (orderBy != null && orderBy!.isNotEmpty) 'orderBy': orderBy!,
    };
  }

  /// Create a copy with updated values
  BaseQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  });

  /// Reset to first page (used when search/sort changes)
  void resetToFirstPage() {
    pageNumber = 1;
  }
}
