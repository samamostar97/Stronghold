import 'base_query_filter.dart';
import '../responses/order_response.dart';

/// Matches backend OrderQueryFilter exactly
class OrderQueryFilter extends BaseQueryFilter {
  OrderStatus? status;
  DateTime? dateFrom;
  DateTime? dateTo;
  bool descending;

  OrderQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
    this.status,
    this.dateFrom,
    this.dateTo,
    this.descending = true,
  });

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();

    if (status != null) {
      params['status'] = status!.index.toString();
    }
    if (dateFrom != null) {
      params['dateFrom'] = dateFrom!.toIso8601String();
    }
    if (dateTo != null) {
      params['dateTo'] = dateTo!.toIso8601String();
    }
    if (descending) {
      params['descending'] = 'true';
    }

    return params;
  }

  @override
  OrderQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
    OrderStatus? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? descending,
  }) {
    return OrderQueryFilter(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      orderBy: orderBy ?? this.orderBy,
      status: status ?? this.status,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      descending: descending ?? this.descending,
    );
  }
}
