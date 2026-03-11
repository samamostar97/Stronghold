// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductResponse {

 int get id; String get name; String? get description; double get price; String? get imageUrl; int get stockQuantity; int get categoryId; String get categoryName; int get supplierId; String get supplierName; DateTime get createdAt;
/// Create a copy of ProductResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductResponseCopyWith<ProductResponse> get copyWith => _$ProductResponseCopyWithImpl<ProductResponse>(this as ProductResponse, _$identity);

  /// Serializes this ProductResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.stockQuantity, stockQuantity) || other.stockQuantity == stockQuantity)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,price,imageUrl,stockQuantity,categoryId,categoryName,supplierId,supplierName,createdAt);

@override
String toString() {
  return 'ProductResponse(id: $id, name: $name, description: $description, price: $price, imageUrl: $imageUrl, stockQuantity: $stockQuantity, categoryId: $categoryId, categoryName: $categoryName, supplierId: $supplierId, supplierName: $supplierName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ProductResponseCopyWith<$Res>  {
  factory $ProductResponseCopyWith(ProductResponse value, $Res Function(ProductResponse) _then) = _$ProductResponseCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? description, double price, String? imageUrl, int stockQuantity, int categoryId, String categoryName, int supplierId, String supplierName, DateTime createdAt
});




}
/// @nodoc
class _$ProductResponseCopyWithImpl<$Res>
    implements $ProductResponseCopyWith<$Res> {
  _$ProductResponseCopyWithImpl(this._self, this._then);

  final ProductResponse _self;
  final $Res Function(ProductResponse) _then;

/// Create a copy of ProductResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? price = null,Object? imageUrl = freezed,Object? stockQuantity = null,Object? categoryId = null,Object? categoryName = null,Object? supplierId = null,Object? supplierName = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,stockQuantity: null == stockQuantity ? _self.stockQuantity : stockQuantity // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int,supplierName: null == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductResponse].
extension ProductResponsePatterns on ProductResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductResponse value)  $default,){
final _that = this;
switch (_that) {
case _ProductResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ProductResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? description,  double price,  String? imageUrl,  int stockQuantity,  int categoryId,  String categoryName,  int supplierId,  String supplierName,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductResponse() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.price,_that.imageUrl,_that.stockQuantity,_that.categoryId,_that.categoryName,_that.supplierId,_that.supplierName,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? description,  double price,  String? imageUrl,  int stockQuantity,  int categoryId,  String categoryName,  int supplierId,  String supplierName,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ProductResponse():
return $default(_that.id,_that.name,_that.description,_that.price,_that.imageUrl,_that.stockQuantity,_that.categoryId,_that.categoryName,_that.supplierId,_that.supplierName,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? description,  double price,  String? imageUrl,  int stockQuantity,  int categoryId,  String categoryName,  int supplierId,  String supplierName,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ProductResponse() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.price,_that.imageUrl,_that.stockQuantity,_that.categoryId,_that.categoryName,_that.supplierId,_that.supplierName,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductResponse implements ProductResponse {
  const _ProductResponse({required this.id, required this.name, this.description, required this.price, this.imageUrl, required this.stockQuantity, required this.categoryId, required this.categoryName, required this.supplierId, required this.supplierName, required this.createdAt});
  factory _ProductResponse.fromJson(Map<String, dynamic> json) => _$ProductResponseFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? description;
@override final  double price;
@override final  String? imageUrl;
@override final  int stockQuantity;
@override final  int categoryId;
@override final  String categoryName;
@override final  int supplierId;
@override final  String supplierName;
@override final  DateTime createdAt;

/// Create a copy of ProductResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductResponseCopyWith<_ProductResponse> get copyWith => __$ProductResponseCopyWithImpl<_ProductResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.stockQuantity, stockQuantity) || other.stockQuantity == stockQuantity)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.supplierId, supplierId) || other.supplierId == supplierId)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,price,imageUrl,stockQuantity,categoryId,categoryName,supplierId,supplierName,createdAt);

@override
String toString() {
  return 'ProductResponse(id: $id, name: $name, description: $description, price: $price, imageUrl: $imageUrl, stockQuantity: $stockQuantity, categoryId: $categoryId, categoryName: $categoryName, supplierId: $supplierId, supplierName: $supplierName, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ProductResponseCopyWith<$Res> implements $ProductResponseCopyWith<$Res> {
  factory _$ProductResponseCopyWith(_ProductResponse value, $Res Function(_ProductResponse) _then) = __$ProductResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? description, double price, String? imageUrl, int stockQuantity, int categoryId, String categoryName, int supplierId, String supplierName, DateTime createdAt
});




}
/// @nodoc
class __$ProductResponseCopyWithImpl<$Res>
    implements _$ProductResponseCopyWith<$Res> {
  __$ProductResponseCopyWithImpl(this._self, this._then);

  final _ProductResponse _self;
  final $Res Function(_ProductResponse) _then;

/// Create a copy of ProductResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? price = null,Object? imageUrl = freezed,Object? stockQuantity = null,Object? categoryId = null,Object? categoryName = null,Object? supplierId = null,Object? supplierName = null,Object? createdAt = null,}) {
  return _then(_ProductResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,stockQuantity: null == stockQuantity ? _self.stockQuantity : stockQuantity // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,supplierId: null == supplierId ? _self.supplierId : supplierId // ignore: cast_nullable_to_non_nullable
as int,supplierName: null == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$PagedProductResponse {

 List<ProductResponse> get items; int get totalCount; int get totalPages; int get currentPage; int get pageSize;
/// Create a copy of PagedProductResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagedProductResponseCopyWith<PagedProductResponse> get copyWith => _$PagedProductResponseCopyWithImpl<PagedProductResponse>(this as PagedProductResponse, _$identity);

  /// Serializes this PagedProductResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagedProductResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedProductResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class $PagedProductResponseCopyWith<$Res>  {
  factory $PagedProductResponseCopyWith(PagedProductResponse value, $Res Function(PagedProductResponse) _then) = _$PagedProductResponseCopyWithImpl;
@useResult
$Res call({
 List<ProductResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class _$PagedProductResponseCopyWithImpl<$Res>
    implements $PagedProductResponseCopyWith<$Res> {
  _$PagedProductResponseCopyWithImpl(this._self, this._then);

  final PagedProductResponse _self;
  final $Res Function(PagedProductResponse) _then;

/// Create a copy of PagedProductResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ProductResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PagedProductResponse].
extension PagedProductResponsePatterns on PagedProductResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PagedProductResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PagedProductResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PagedProductResponse value)  $default,){
final _that = this;
switch (_that) {
case _PagedProductResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PagedProductResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PagedProductResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ProductResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PagedProductResponse() when $default != null:
return $default(_that.items,_that.totalCount,_that.totalPages,_that.currentPage,_that.pageSize);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ProductResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)  $default,) {final _that = this;
switch (_that) {
case _PagedProductResponse():
return $default(_that.items,_that.totalCount,_that.totalPages,_that.currentPage,_that.pageSize);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ProductResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,) {final _that = this;
switch (_that) {
case _PagedProductResponse() when $default != null:
return $default(_that.items,_that.totalCount,_that.totalPages,_that.currentPage,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PagedProductResponse implements PagedProductResponse {
  const _PagedProductResponse({required final  List<ProductResponse> items, required this.totalCount, required this.totalPages, required this.currentPage, required this.pageSize}): _items = items;
  factory _PagedProductResponse.fromJson(Map<String, dynamic> json) => _$PagedProductResponseFromJson(json);

 final  List<ProductResponse> _items;
@override List<ProductResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int totalCount;
@override final  int totalPages;
@override final  int currentPage;
@override final  int pageSize;

/// Create a copy of PagedProductResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagedProductResponseCopyWith<_PagedProductResponse> get copyWith => __$PagedProductResponseCopyWithImpl<_PagedProductResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PagedProductResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagedProductResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedProductResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$PagedProductResponseCopyWith<$Res> implements $PagedProductResponseCopyWith<$Res> {
  factory _$PagedProductResponseCopyWith(_PagedProductResponse value, $Res Function(_PagedProductResponse) _then) = __$PagedProductResponseCopyWithImpl;
@override @useResult
$Res call({
 List<ProductResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class __$PagedProductResponseCopyWithImpl<$Res>
    implements _$PagedProductResponseCopyWith<$Res> {
  __$PagedProductResponseCopyWithImpl(this._self, this._then);

  final _PagedProductResponse _self;
  final $Res Function(_PagedProductResponse) _then;

/// Create a copy of PagedProductResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_PagedProductResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ProductResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
