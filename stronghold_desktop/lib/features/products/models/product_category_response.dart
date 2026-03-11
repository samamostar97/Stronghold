import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_category_response.freezed.dart';
part 'product_category_response.g.dart';

@freezed
abstract class ProductCategoryResponse with _$ProductCategoryResponse {
  const factory ProductCategoryResponse({
    required int id,
    required String name,
    String? description,
  }) = _ProductCategoryResponse;

  factory ProductCategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoryResponseFromJson(json);
}
