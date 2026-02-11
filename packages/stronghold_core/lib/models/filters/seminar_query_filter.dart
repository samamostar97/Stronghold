import 'base_query_filter.dart';

/// Matches backend SeminarQueryFilter exactly
class SeminarQueryFilter extends BaseQueryFilter {
  bool? isCancelled;
  String? status;

  SeminarQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
    this.isCancelled,
    this.status,
  });

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();
    if (isCancelled != null) {
      params['isCancelled'] = isCancelled.toString();
    }
    if (status != null && status!.isNotEmpty) {
      params['status'] = status!;
    }
    return params;
  }

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
      isCancelled: this.isCancelled,
      status: this.status,
    );
  }
}
