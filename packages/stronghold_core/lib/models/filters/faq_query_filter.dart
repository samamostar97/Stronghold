import 'base_query_filter.dart';

/// Matches backend FaqQueryFilter exactly
class FaqQueryFilter extends BaseQueryFilter {
  FaqQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
  });

  @override
  FaqQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    return FaqQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
    );
  }
}
