import 'base_query_filter.dart';

/// Matches backend SupplementQueryFilter exactly
class SupplementQueryFilter extends BaseQueryFilter {
  int? supplementCategoryId;

  SupplementQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
    this.supplementCategoryId,
  });

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();
    if (supplementCategoryId != null) {
      params['SupplementCategoryId'] = supplementCategoryId.toString();
    }
    return params;
  }

  @override
  SupplementQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
    int? supplementCategoryId,
  }) {
    return SupplementQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
      supplementCategoryId: supplementCategoryId ?? this.supplementCategoryId,
    );
  }
}
