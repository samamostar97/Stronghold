import 'base_query_filter.dart';

/// Matches backend TrainerQueryFilter exactly
class TrainerQueryFilter extends BaseQueryFilter {
  TrainerQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
  });

  @override
  TrainerQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
  }) {
    return TrainerQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
    );
  }
}
