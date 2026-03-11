// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderResponse {

 int get id; int get userId; String get userName; double get totalAmount; String get deliveryAddress; String get status; String? get stripePaymentIntentId; String? get clientSecret; DateTime get createdAt; List<OrderItemResponse> get items;
/// Create a copy of OrderResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderResponseCopyWith<OrderResponse> get copyWith => _$OrderResponseCopyWithImpl<OrderResponse>(this as OrderResponse, _$identity);

  /// Serializes this OrderResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&(identical(other.status, status) || other.status == status)&&(identical(other.stripePaymentIntentId, stripePaymentIntentId) || other.stripePaymentIntentId == stripePaymentIntentId)&&(identical(other.clientSecret, clientSecret) || other.clientSecret == clientSecret)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,totalAmount,deliveryAddress,status,stripePaymentIntentId,clientSecret,createdAt,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'OrderResponse(id: $id, userId: $userId, userName: $userName, totalAmount: $totalAmount, deliveryAddress: $deliveryAddress, status: $status, stripePaymentIntentId: $stripePaymentIntentId, clientSecret: $clientSecret, createdAt: $createdAt, items: $items)';
}


}

/// @nodoc
abstract mixin class $OrderResponseCopyWith<$Res>  {
  factory $OrderResponseCopyWith(OrderResponse value, $Res Function(OrderResponse) _then) = _$OrderResponseCopyWithImpl;
@useResult
$Res call({
 int id, int userId, String userName, double totalAmount, String deliveryAddress, String status, String? stripePaymentIntentId, String? clientSecret, DateTime createdAt, List<OrderItemResponse> items
});




}
/// @nodoc
class _$OrderResponseCopyWithImpl<$Res>
    implements $OrderResponseCopyWith<$Res> {
  _$OrderResponseCopyWithImpl(this._self, this._then);

  final OrderResponse _self;
  final $Res Function(OrderResponse) _then;

/// Create a copy of OrderResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? userName = null,Object? totalAmount = null,Object? deliveryAddress = null,Object? status = null,Object? stripePaymentIntentId = freezed,Object? clientSecret = freezed,Object? createdAt = null,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,deliveryAddress: null == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,stripePaymentIntentId: freezed == stripePaymentIntentId ? _self.stripePaymentIntentId : stripePaymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,clientSecret: freezed == clientSecret ? _self.clientSecret : clientSecret // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItemResponse>,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderResponse].
extension OrderResponsePatterns on OrderResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderResponse value)  $default,){
final _that = this;
switch (_that) {
case _OrderResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderResponse value)?  $default,){
final _that = this;
switch (_that) {
case _OrderResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int userId,  String userName,  double totalAmount,  String deliveryAddress,  String status,  String? stripePaymentIntentId,  String? clientSecret,  DateTime createdAt,  List<OrderItemResponse> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderResponse() when $default != null:
return $default(_that.id,_that.userId,_that.userName,_that.totalAmount,_that.deliveryAddress,_that.status,_that.stripePaymentIntentId,_that.clientSecret,_that.createdAt,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int userId,  String userName,  double totalAmount,  String deliveryAddress,  String status,  String? stripePaymentIntentId,  String? clientSecret,  DateTime createdAt,  List<OrderItemResponse> items)  $default,) {final _that = this;
switch (_that) {
case _OrderResponse():
return $default(_that.id,_that.userId,_that.userName,_that.totalAmount,_that.deliveryAddress,_that.status,_that.stripePaymentIntentId,_that.clientSecret,_that.createdAt,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int userId,  String userName,  double totalAmount,  String deliveryAddress,  String status,  String? stripePaymentIntentId,  String? clientSecret,  DateTime createdAt,  List<OrderItemResponse> items)?  $default,) {final _that = this;
switch (_that) {
case _OrderResponse() when $default != null:
return $default(_that.id,_that.userId,_that.userName,_that.totalAmount,_that.deliveryAddress,_that.status,_that.stripePaymentIntentId,_that.clientSecret,_that.createdAt,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderResponse implements OrderResponse {
  const _OrderResponse({required this.id, required this.userId, required this.userName, required this.totalAmount, required this.deliveryAddress, required this.status, this.stripePaymentIntentId, this.clientSecret, required this.createdAt, final  List<OrderItemResponse> items = const []}): _items = items;
  factory _OrderResponse.fromJson(Map<String, dynamic> json) => _$OrderResponseFromJson(json);

@override final  int id;
@override final  int userId;
@override final  String userName;
@override final  double totalAmount;
@override final  String deliveryAddress;
@override final  String status;
@override final  String? stripePaymentIntentId;
@override final  String? clientSecret;
@override final  DateTime createdAt;
 final  List<OrderItemResponse> _items;
@override@JsonKey() List<OrderItemResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of OrderResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderResponseCopyWith<_OrderResponse> get copyWith => __$OrderResponseCopyWithImpl<_OrderResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&(identical(other.status, status) || other.status == status)&&(identical(other.stripePaymentIntentId, stripePaymentIntentId) || other.stripePaymentIntentId == stripePaymentIntentId)&&(identical(other.clientSecret, clientSecret) || other.clientSecret == clientSecret)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,totalAmount,deliveryAddress,status,stripePaymentIntentId,clientSecret,createdAt,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'OrderResponse(id: $id, userId: $userId, userName: $userName, totalAmount: $totalAmount, deliveryAddress: $deliveryAddress, status: $status, stripePaymentIntentId: $stripePaymentIntentId, clientSecret: $clientSecret, createdAt: $createdAt, items: $items)';
}


}

/// @nodoc
abstract mixin class _$OrderResponseCopyWith<$Res> implements $OrderResponseCopyWith<$Res> {
  factory _$OrderResponseCopyWith(_OrderResponse value, $Res Function(_OrderResponse) _then) = __$OrderResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, int userId, String userName, double totalAmount, String deliveryAddress, String status, String? stripePaymentIntentId, String? clientSecret, DateTime createdAt, List<OrderItemResponse> items
});




}
/// @nodoc
class __$OrderResponseCopyWithImpl<$Res>
    implements _$OrderResponseCopyWith<$Res> {
  __$OrderResponseCopyWithImpl(this._self, this._then);

  final _OrderResponse _self;
  final $Res Function(_OrderResponse) _then;

/// Create a copy of OrderResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? userName = null,Object? totalAmount = null,Object? deliveryAddress = null,Object? status = null,Object? stripePaymentIntentId = freezed,Object? clientSecret = freezed,Object? createdAt = null,Object? items = null,}) {
  return _then(_OrderResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,deliveryAddress: null == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,stripePaymentIntentId: freezed == stripePaymentIntentId ? _self.stripePaymentIntentId : stripePaymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,clientSecret: freezed == clientSecret ? _self.clientSecret : clientSecret // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItemResponse>,
  ));
}


}


/// @nodoc
mixin _$OrderItemResponse {

 int get id; int get productId; String get productName; String? get productImageUrl; int get quantity; double get unitPrice; double get subtotal;
/// Create a copy of OrderItemResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemResponseCopyWith<OrderItemResponse> get copyWith => _$OrderItemResponseCopyWithImpl<OrderItemResponse>(this as OrderItemResponse, _$identity);

  /// Serializes this OrderItemResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItemResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productImageUrl, productImageUrl) || other.productImageUrl == productImageUrl)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,productName,productImageUrl,quantity,unitPrice,subtotal);

@override
String toString() {
  return 'OrderItemResponse(id: $id, productId: $productId, productName: $productName, productImageUrl: $productImageUrl, quantity: $quantity, unitPrice: $unitPrice, subtotal: $subtotal)';
}


}

/// @nodoc
abstract mixin class $OrderItemResponseCopyWith<$Res>  {
  factory $OrderItemResponseCopyWith(OrderItemResponse value, $Res Function(OrderItemResponse) _then) = _$OrderItemResponseCopyWithImpl;
@useResult
$Res call({
 int id, int productId, String productName, String? productImageUrl, int quantity, double unitPrice, double subtotal
});




}
/// @nodoc
class _$OrderItemResponseCopyWithImpl<$Res>
    implements $OrderItemResponseCopyWith<$Res> {
  _$OrderItemResponseCopyWithImpl(this._self, this._then);

  final OrderItemResponse _self;
  final $Res Function(OrderItemResponse) _then;

/// Create a copy of OrderItemResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? productName = null,Object? productImageUrl = freezed,Object? quantity = null,Object? unitPrice = null,Object? subtotal = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,productImageUrl: freezed == productImageUrl ? _self.productImageUrl : productImageUrl // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderItemResponse].
extension OrderItemResponsePatterns on OrderItemResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItemResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItemResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItemResponse value)  $default,){
final _that = this;
switch (_that) {
case _OrderItemResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItemResponse value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItemResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int productId,  String productName,  String? productImageUrl,  int quantity,  double unitPrice,  double subtotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItemResponse() when $default != null:
return $default(_that.id,_that.productId,_that.productName,_that.productImageUrl,_that.quantity,_that.unitPrice,_that.subtotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int productId,  String productName,  String? productImageUrl,  int quantity,  double unitPrice,  double subtotal)  $default,) {final _that = this;
switch (_that) {
case _OrderItemResponse():
return $default(_that.id,_that.productId,_that.productName,_that.productImageUrl,_that.quantity,_that.unitPrice,_that.subtotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int productId,  String productName,  String? productImageUrl,  int quantity,  double unitPrice,  double subtotal)?  $default,) {final _that = this;
switch (_that) {
case _OrderItemResponse() when $default != null:
return $default(_that.id,_that.productId,_that.productName,_that.productImageUrl,_that.quantity,_that.unitPrice,_that.subtotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderItemResponse implements OrderItemResponse {
  const _OrderItemResponse({required this.id, required this.productId, required this.productName, this.productImageUrl, required this.quantity, required this.unitPrice, required this.subtotal});
  factory _OrderItemResponse.fromJson(Map<String, dynamic> json) => _$OrderItemResponseFromJson(json);

@override final  int id;
@override final  int productId;
@override final  String productName;
@override final  String? productImageUrl;
@override final  int quantity;
@override final  double unitPrice;
@override final  double subtotal;

/// Create a copy of OrderItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemResponseCopyWith<_OrderItemResponse> get copyWith => __$OrderItemResponseCopyWithImpl<_OrderItemResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderItemResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItemResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productImageUrl, productImageUrl) || other.productImageUrl == productImageUrl)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,productName,productImageUrl,quantity,unitPrice,subtotal);

@override
String toString() {
  return 'OrderItemResponse(id: $id, productId: $productId, productName: $productName, productImageUrl: $productImageUrl, quantity: $quantity, unitPrice: $unitPrice, subtotal: $subtotal)';
}


}

/// @nodoc
abstract mixin class _$OrderItemResponseCopyWith<$Res> implements $OrderItemResponseCopyWith<$Res> {
  factory _$OrderItemResponseCopyWith(_OrderItemResponse value, $Res Function(_OrderItemResponse) _then) = __$OrderItemResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, int productId, String productName, String? productImageUrl, int quantity, double unitPrice, double subtotal
});




}
/// @nodoc
class __$OrderItemResponseCopyWithImpl<$Res>
    implements _$OrderItemResponseCopyWith<$Res> {
  __$OrderItemResponseCopyWithImpl(this._self, this._then);

  final _OrderItemResponse _self;
  final $Res Function(_OrderItemResponse) _then;

/// Create a copy of OrderItemResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? productName = null,Object? productImageUrl = freezed,Object? quantity = null,Object? unitPrice = null,Object? subtotal = null,}) {
  return _then(_OrderItemResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,productImageUrl: freezed == productImageUrl ? _self.productImageUrl : productImageUrl // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$PagedOrderResponse {

 List<OrderResponse> get items; int get totalCount; int get totalPages; int get currentPage; int get pageSize;
/// Create a copy of PagedOrderResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagedOrderResponseCopyWith<PagedOrderResponse> get copyWith => _$PagedOrderResponseCopyWithImpl<PagedOrderResponse>(this as PagedOrderResponse, _$identity);

  /// Serializes this PagedOrderResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagedOrderResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedOrderResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class $PagedOrderResponseCopyWith<$Res>  {
  factory $PagedOrderResponseCopyWith(PagedOrderResponse value, $Res Function(PagedOrderResponse) _then) = _$PagedOrderResponseCopyWithImpl;
@useResult
$Res call({
 List<OrderResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class _$PagedOrderResponseCopyWithImpl<$Res>
    implements $PagedOrderResponseCopyWith<$Res> {
  _$PagedOrderResponseCopyWithImpl(this._self, this._then);

  final PagedOrderResponse _self;
  final $Res Function(PagedOrderResponse) _then;

/// Create a copy of PagedOrderResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PagedOrderResponse].
extension PagedOrderResponsePatterns on PagedOrderResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PagedOrderResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PagedOrderResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PagedOrderResponse value)  $default,){
final _that = this;
switch (_that) {
case _PagedOrderResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PagedOrderResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PagedOrderResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OrderResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PagedOrderResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OrderResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)  $default,) {final _that = this;
switch (_that) {
case _PagedOrderResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OrderResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,) {final _that = this;
switch (_that) {
case _PagedOrderResponse() when $default != null:
return $default(_that.items,_that.totalCount,_that.totalPages,_that.currentPage,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PagedOrderResponse implements PagedOrderResponse {
  const _PagedOrderResponse({required final  List<OrderResponse> items, required this.totalCount, required this.totalPages, required this.currentPage, required this.pageSize}): _items = items;
  factory _PagedOrderResponse.fromJson(Map<String, dynamic> json) => _$PagedOrderResponseFromJson(json);

 final  List<OrderResponse> _items;
@override List<OrderResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int totalCount;
@override final  int totalPages;
@override final  int currentPage;
@override final  int pageSize;

/// Create a copy of PagedOrderResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagedOrderResponseCopyWith<_PagedOrderResponse> get copyWith => __$PagedOrderResponseCopyWithImpl<_PagedOrderResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PagedOrderResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagedOrderResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedOrderResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$PagedOrderResponseCopyWith<$Res> implements $PagedOrderResponseCopyWith<$Res> {
  factory _$PagedOrderResponseCopyWith(_PagedOrderResponse value, $Res Function(_PagedOrderResponse) _then) = __$PagedOrderResponseCopyWithImpl;
@override @useResult
$Res call({
 List<OrderResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class __$PagedOrderResponseCopyWithImpl<$Res>
    implements _$PagedOrderResponseCopyWith<$Res> {
  __$PagedOrderResponseCopyWithImpl(this._self, this._then);

  final _PagedOrderResponse _self;
  final $Res Function(_PagedOrderResponse) _then;

/// Create a copy of PagedOrderResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_PagedOrderResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
