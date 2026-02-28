import 'base_query_filter.dart';
import '../responses/order_response.dart';

/// Matches backend OrderQueryFilter exactly
class OrderQueryFilter extends BaseQueryFilter {
  OrderStatus? status;
  int? userId;
  DateTime? dateFrom;
  DateTime? dateTo;
  bool descending;

  OrderQueryFilter({
    super.pageNumber,
    super.pageSize,
    super.search,
    super.orderBy,
    this.status,
    this.userId,
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
    if (userId != null) {
      params['userId'] = userId.toString();
    }
    if (dateFrom != null) {
      params['dateFrom'] = dateFrom!.toIso8601String();
    }
    if (dateTo != null) {
      params['dateTo'] = dateTo!.toIso8601String();
    }
    params['descending'] = descending.toString();

    return params;
  }

  @override
  OrderQueryFilter copyWith({
    int? pageNumber,
    int? pageSize,
    String? search,
    String? orderBy,
    OrderStatus? status,
    int? userId,
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
      userId: userId ?? this.userId,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      descending: descending ?? this.descending,
    );
  }
}
