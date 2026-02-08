import 'base_query_filter.dart';

/// Filter for paginated slow-moving products report
class SlowMovingProductQueryFilter extends BaseQueryFilter {
  int daysToAnalyze;

  SlowMovingProductQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
    this.daysToAnalyze = 30,
  });

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();
    params['daysToAnalyze'] = daysToAnalyze.toString();
    return params;
  }

  @override
  SlowMovingProductQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
    int? daysToAnalyze,
  }) {
    return SlowMovingProductQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
      daysToAnalyze: daysToAnalyze ?? this.daysToAnalyze,
    );
  }
}
