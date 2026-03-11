import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_response.freezed.dart';
part 'product_response.g.dart';

@freezed
abstract class ProductResponse with _$ProductResponse {
  const factory ProductResponse({
    required int id,
    required String name,
    String? description,
    required double price,
    String? imageUrl,
    required int stockQuantity,
    required int categoryId,
    required String categoryName,
    required int supplierId,
    required String supplierName,
    required DateTime createdAt,
  }) = _ProductResponse;

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseFromJson(json);
}

@freezed
abstract class PagedProductResponse with _$PagedProductResponse {
  const factory PagedProductResponse({
    required List<ProductResponse> items,
    required int totalCount,
    required int totalPages,
    required int currentPage,
    required int pageSize,
  }) = _PagedProductResponse;

  factory PagedProductResponse.fromJson(Map<String, dynamic> json) =>
      _$PagedProductResponseFromJson(json);
}
