import 'package:freezed_annotation/freezed_annotation.dart';

part 'supplier_response.freezed.dart';
part 'supplier_response.g.dart';

@freezed
abstract class SupplierResponse with _$SupplierResponse {
  const factory SupplierResponse({
    required int id,
    required String name,
    String? email,
    String? phone,
    String? website,
    required DateTime createdAt,
  }) = _SupplierResponse;

  factory SupplierResponse.fromJson(Map<String, dynamic> json) =>
      _$SupplierResponseFromJson(json);
}

@freezed
abstract class PagedSupplierResponse with _$PagedSupplierResponse {
  const factory PagedSupplierResponse({
    required List<SupplierResponse> items,
    required int totalCount,
    required int totalPages,
    required int currentPage,
    required int pageSize,
  }) = _PagedSupplierResponse;

  factory PagedSupplierResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedSupplierResponseFromJson(json);
}
