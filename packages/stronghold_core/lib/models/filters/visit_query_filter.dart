import 'base_query_filter.dart';

/// Filter for current visitors query.
/// Matches backend VisitFilter (Search + OrderBy + pagination).
class VisitQueryFilter extends BaseQueryFilter {
  VisitQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
  });

  @override
  VisitQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    return VisitQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
    );
  }
}
