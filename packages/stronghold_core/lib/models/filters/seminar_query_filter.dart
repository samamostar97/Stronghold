import 'base_query_filter.dart';

/// Matches backend SeminarQueryFilter exactly
class SeminarQueryFilter extends BaseQueryFilter {
  SeminarQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
  });

  @override
  SeminarQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    return SeminarQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
    );
  }
}
