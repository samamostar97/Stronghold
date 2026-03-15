// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RevenueReportData {

 DateTime get from; DateTime get to; double get orderRevenue; double get membershipRevenue; double get totalRevenue; int get orderCount; int get membershipCount;
/// Create a copy of RevenueReportData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RevenueReportDataCopyWith<RevenueReportData> get copyWith => _$RevenueReportDataCopyWithImpl<RevenueReportData>(this as RevenueReportData, _$identity);

  /// Serializes this RevenueReportData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RevenueReportData&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.orderRevenue, orderRevenue) || other.orderRevenue == orderRevenue)&&(identical(other.membershipRevenue, membershipRevenue) || other.membershipRevenue == membershipRevenue)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.orderCount, orderCount) || other.orderCount == orderCount)&&(identical(other.membershipCount, membershipCount) || other.membershipCount == membershipCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,from,to,orderRevenue,membershipRevenue,totalRevenue,orderCount,membershipCount);

@override
String toString() {
  return 'RevenueReportData(from: $from, to: $to, orderRevenue: $orderRevenue, membershipRevenue: $membershipRevenue, totalRevenue: $totalRevenue, orderCount: $orderCount, membershipCount: $membershipCount)';
}


}

/// @nodoc
abstract mixin class $RevenueReportDataCopyWith<$Res>  {
  factory $RevenueReportDataCopyWith(RevenueReportData value, $Res Function(RevenueReportData) _then) = _$RevenueReportDataCopyWithImpl;
@useResult
$Res call({
 DateTime from, DateTime to, double orderRevenue, double membershipRevenue, double totalRevenue, int orderCount, int membershipCount
});




}
/// @nodoc
class _$RevenueReportDataCopyWithImpl<$Res>
    implements $RevenueReportDataCopyWith<$Res> {
  _$RevenueReportDataCopyWithImpl(this._self, this._then);

  final RevenueReportData _self;
  final $Res Function(RevenueReportData) _then;

/// Create a copy of RevenueReportData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? from = null,Object? to = null,Object? orderRevenue = null,Object? membershipRevenue = null,Object? totalRevenue = null,Object? orderCount = null,Object? membershipCount = null,}) {
  return _then(_self.copyWith(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,orderRevenue: null == orderRevenue ? _self.orderRevenue : orderRevenue // ignore: cast_nullable_to_non_nullable
as double,membershipRevenue: null == membershipRevenue ? _self.membershipRevenue : membershipRevenue // ignore: cast_nullable_to_non_nullable
as double,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,orderCount: null == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as int,membershipCount: null == membershipCount ? _self.membershipCount : membershipCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RevenueReportData].
extension RevenueReportDataPatterns on RevenueReportData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RevenueReportData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RevenueReportData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RevenueReportData value)  $default,){
final _that = this;
switch (_that) {
case _RevenueReportData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RevenueReportData value)?  $default,){
final _that = this;
switch (_that) {
case _RevenueReportData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime from,  DateTime to,  double orderRevenue,  double membershipRevenue,  double totalRevenue,  int orderCount,  int membershipCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RevenueReportData() when $default != null:
return $default(_that.from,_that.to,_that.orderRevenue,_that.membershipRevenue,_that.totalRevenue,_that.orderCount,_that.membershipCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime from,  DateTime to,  double orderRevenue,  double membershipRevenue,  double totalRevenue,  int orderCount,  int membershipCount)  $default,) {final _that = this;
switch (_that) {
case _RevenueReportData():
return $default(_that.from,_that.to,_that.orderRevenue,_that.membershipRevenue,_that.totalRevenue,_that.orderCount,_that.membershipCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime from,  DateTime to,  double orderRevenue,  double membershipRevenue,  double totalRevenue,  int orderCount,  int membershipCount)?  $default,) {final _that = this;
switch (_that) {
case _RevenueReportData() when $default != null:
return $default(_that.from,_that.to,_that.orderRevenue,_that.membershipRevenue,_that.totalRevenue,_that.orderCount,_that.membershipCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RevenueReportData implements RevenueReportData {
  const _RevenueReportData({required this.from, required this.to, required this.orderRevenue, required this.membershipRevenue, required this.totalRevenue, required this.orderCount, required this.membershipCount});
  factory _RevenueReportData.fromJson(Map<String, dynamic> json) => _$RevenueReportDataFromJson(json);

@override final  DateTime from;
@override final  DateTime to;
@override final  double orderRevenue;
@override final  double membershipRevenue;
@override final  double totalRevenue;
@override final  int orderCount;
@override final  int membershipCount;

/// Create a copy of RevenueReportData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RevenueReportDataCopyWith<_RevenueReportData> get copyWith => __$RevenueReportDataCopyWithImpl<_RevenueReportData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RevenueReportDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RevenueReportData&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.orderRevenue, orderRevenue) || other.orderRevenue == orderRevenue)&&(identical(other.membershipRevenue, membershipRevenue) || other.membershipRevenue == membershipRevenue)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.orderCount, orderCount) || other.orderCount == orderCount)&&(identical(other.membershipCount, membershipCount) || other.membershipCount == membershipCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,from,to,orderRevenue,membershipRevenue,totalRevenue,orderCount,membershipCount);

@override
String toString() {
  return 'RevenueReportData(from: $from, to: $to, orderRevenue: $orderRevenue, membershipRevenue: $membershipRevenue, totalRevenue: $totalRevenue, orderCount: $orderCount, membershipCount: $membershipCount)';
}


}

/// @nodoc
abstract mixin class _$RevenueReportDataCopyWith<$Res> implements $RevenueReportDataCopyWith<$Res> {
  factory _$RevenueReportDataCopyWith(_RevenueReportData value, $Res Function(_RevenueReportData) _then) = __$RevenueReportDataCopyWithImpl;
@override @useResult
$Res call({
 DateTime from, DateTime to, double orderRevenue, double membershipRevenue, double totalRevenue, int orderCount, int membershipCount
});




}
/// @nodoc
class __$RevenueReportDataCopyWithImpl<$Res>
    implements _$RevenueReportDataCopyWith<$Res> {
  __$RevenueReportDataCopyWithImpl(this._self, this._then);

  final _RevenueReportData _self;
  final $Res Function(_RevenueReportData) _then;

/// Create a copy of RevenueReportData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,Object? orderRevenue = null,Object? membershipRevenue = null,Object? totalRevenue = null,Object? orderCount = null,Object? membershipCount = null,}) {
  return _then(_RevenueReportData(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,orderRevenue: null == orderRevenue ? _self.orderRevenue : orderRevenue // ignore: cast_nullable_to_non_nullable
as double,membershipRevenue: null == membershipRevenue ? _self.membershipRevenue : membershipRevenue // ignore: cast_nullable_to_non_nullable
as double,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,orderCount: null == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as int,membershipCount: null == membershipCount ? _self.membershipCount : membershipCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$OrderRevenueReportData {

 DateTime get from; DateTime get to; double get totalRevenue; int get totalOrders; List<OrderRevenueItem> get items;
/// Create a copy of OrderRevenueReportData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderRevenueReportDataCopyWith<OrderRevenueReportData> get copyWith => _$OrderRevenueReportDataCopyWithImpl<OrderRevenueReportData>(this as OrderRevenueReportData, _$identity);

  /// Serializes this OrderRevenueReportData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderRevenueReportData&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,from,to,totalRevenue,totalOrders,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'OrderRevenueReportData(from: $from, to: $to, totalRevenue: $totalRevenue, totalOrders: $totalOrders, items: $items)';
}


}

/// @nodoc
abstract mixin class $OrderRevenueReportDataCopyWith<$Res>  {
  factory $OrderRevenueReportDataCopyWith(OrderRevenueReportData value, $Res Function(OrderRevenueReportData) _then) = _$OrderRevenueReportDataCopyWithImpl;
@useResult
$Res call({
 DateTime from, DateTime to, double totalRevenue, int totalOrders, List<OrderRevenueItem> items
});




}
/// @nodoc
class _$OrderRevenueReportDataCopyWithImpl<$Res>
    implements $OrderRevenueReportDataCopyWith<$Res> {
  _$OrderRevenueReportDataCopyWithImpl(this._self, this._then);

  final OrderRevenueReportData _self;
  final $Res Function(OrderRevenueReportData) _then;

/// Create a copy of OrderRevenueReportData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? from = null,Object? to = null,Object? totalRevenue = null,Object? totalOrders = null,Object? items = null,}) {
  return _then(_self.copyWith(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderRevenueItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderRevenueReportData].
extension OrderRevenueReportDataPatterns on OrderRevenueReportData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderRevenueReportData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderRevenueReportData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderRevenueReportData value)  $default,){
final _that = this;
switch (_that) {
case _OrderRevenueReportData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderRevenueReportData value)?  $default,){
final _that = this;
switch (_that) {
case _OrderRevenueReportData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime from,  DateTime to,  double totalRevenue,  int totalOrders,  List<OrderRevenueItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderRevenueReportData() when $default != null:
return $default(_that.from,_that.to,_that.totalRevenue,_that.totalOrders,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime from,  DateTime to,  double totalRevenue,  int totalOrders,  List<OrderRevenueItem> items)  $default,) {final _that = this;
switch (_that) {
case _OrderRevenueReportData():
return $default(_that.from,_that.to,_that.totalRevenue,_that.totalOrders,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime from,  DateTime to,  double totalRevenue,  int totalOrders,  List<OrderRevenueItem> items)?  $default,) {final _that = this;
switch (_that) {
case _OrderRevenueReportData() when $default != null:
return $default(_that.from,_that.to,_that.totalRevenue,_that.totalOrders,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderRevenueReportData implements OrderRevenueReportData {
  const _OrderRevenueReportData({required this.from, required this.to, required this.totalRevenue, required this.totalOrders, final  List<OrderRevenueItem> items = const []}): _items = items;
  factory _OrderRevenueReportData.fromJson(Map<String, dynamic> json) => _$OrderRevenueReportDataFromJson(json);

@override final  DateTime from;
@override final  DateTime to;
@override final  double totalRevenue;
@override final  int totalOrders;
 final  List<OrderRevenueItem> _items;
@override@JsonKey() List<OrderRevenueItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of OrderRevenueReportData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderRevenueReportDataCopyWith<_OrderRevenueReportData> get copyWith => __$OrderRevenueReportDataCopyWithImpl<_OrderRevenueReportData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderRevenueReportDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderRevenueReportData&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalOrders, totalOrders) || other.totalOrders == totalOrders)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,from,to,totalRevenue,totalOrders,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'OrderRevenueReportData(from: $from, to: $to, totalRevenue: $totalRevenue, totalOrders: $totalOrders, items: $items)';
}


}

/// @nodoc
abstract mixin class _$OrderRevenueReportDataCopyWith<$Res> implements $OrderRevenueReportDataCopyWith<$Res> {
  factory _$OrderRevenueReportDataCopyWith(_OrderRevenueReportData value, $Res Function(_OrderRevenueReportData) _then) = __$OrderRevenueReportDataCopyWithImpl;
@override @useResult
$Res call({
 DateTime from, DateTime to, double totalRevenue, int totalOrders, List<OrderRevenueItem> items
});




}
/// @nodoc
class __$OrderRevenueReportDataCopyWithImpl<$Res>
    implements _$OrderRevenueReportDataCopyWith<$Res> {
  __$OrderRevenueReportDataCopyWithImpl(this._self, this._then);

  final _OrderRevenueReportData _self;
  final $Res Function(_OrderRevenueReportData) _then;

/// Create a copy of OrderRevenueReportData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,Object? totalRevenue = null,Object? totalOrders = null,Object? items = null,}) {
  return _then(_OrderRevenueReportData(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalOrders: null == totalOrders ? _self.totalOrders : totalOrders // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderRevenueItem>,
  ));
}


}


/// @nodoc
mixin _$OrderRevenueItem {

 int get orderId; String get userName; double get totalAmount; String get status; DateTime get createdAt;
/// Create a copy of OrderRevenueItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderRevenueItemCopyWith<OrderRevenueItem> get copyWith => _$OrderRevenueItemCopyWithImpl<OrderRevenueItem>(this as OrderRevenueItem, _$identity);

  /// Serializes this OrderRevenueItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderRevenueItem&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderId,userName,totalAmount,status,createdAt);

@override
String toString() {
  return 'OrderRevenueItem(orderId: $orderId, userName: $userName, totalAmount: $totalAmount, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $OrderRevenueItemCopyWith<$Res>  {
  factory $OrderRevenueItemCopyWith(OrderRevenueItem value, $Res Function(OrderRevenueItem) _then) = _$OrderRevenueItemCopyWithImpl;
@useResult
$Res call({
 int orderId, String userName, double totalAmount, String status, DateTime createdAt
});




}
/// @nodoc
class _$OrderRevenueItemCopyWithImpl<$Res>
    implements $OrderRevenueItemCopyWith<$Res> {
  _$OrderRevenueItemCopyWithImpl(this._self, this._then);

  final OrderRevenueItem _self;
  final $Res Function(OrderRevenueItem) _then;

/// Create a copy of OrderRevenueItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderId = null,Object? userName = null,Object? totalAmount = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderRevenueItem].
extension OrderRevenueItemPatterns on OrderRevenueItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderRevenueItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderRevenueItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderRevenueItem value)  $default,){
final _that = this;
switch (_that) {
case _OrderRevenueItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderRevenueItem value)?  $default,){
final _that = this;
switch (_that) {
case _OrderRevenueItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int orderId,  String userName,  double totalAmount,  String status,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderRevenueItem() when $default != null:
return $default(_that.orderId,_that.userName,_that.totalAmount,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int orderId,  String userName,  double totalAmount,  String status,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _OrderRevenueItem():
return $default(_that.orderId,_that.userName,_that.totalAmount,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int orderId,  String userName,  double totalAmount,  String status,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderRevenueItem() when $default != null:
return $default(_that.orderId,_that.userName,_that.totalAmount,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderRevenueItem implements OrderRevenueItem {
  const _OrderRevenueItem({required this.orderId, required this.userName, required this.totalAmount, required this.status, required this.createdAt});
  factory _OrderRevenueItem.fromJson(Map<String, dynamic> json) => _$OrderRevenueItemFromJson(json);

@override final  int orderId;
@override final  String userName;
@override final  double totalAmount;
@override final  String status;
@override final  DateTime createdAt;

/// Create a copy of OrderRevenueItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderRevenueItemCopyWith<_OrderRevenueItem> get copyWith => __$OrderRevenueItemCopyWithImpl<_OrderRevenueItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderRevenueItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderRevenueItem&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderId,userName,totalAmount,status,createdAt);

@override
String toString() {
  return 'OrderRevenueItem(orderId: $orderId, userName: $userName, totalAmount: $totalAmount, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$OrderRevenueItemCopyWith<$Res> implements $OrderRevenueItemCopyWith<$Res> {
  factory _$OrderRevenueItemCopyWith(_OrderRevenueItem value, $Res Function(_OrderRevenueItem) _then) = __$OrderRevenueItemCopyWithImpl;
@override @useResult
$Res call({
 int orderId, String userName, double totalAmount, String status, DateTime createdAt
});




}
/// @nodoc
class __$OrderRevenueItemCopyWithImpl<$Res>
    implements _$OrderRevenueItemCopyWith<$Res> {
  __$OrderRevenueItemCopyWithImpl(this._self, this._then);

  final _OrderRevenueItem _self;
  final $Res Function(_OrderRevenueItem) _then;

/// Create a copy of OrderRevenueItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderId = null,Object? userName = null,Object? totalAmount = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_OrderRevenueItem(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as int,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$MembershipRevenueReportData {

 DateTime get from; DateTime get to; double get totalRevenue; int get totalMemberships; List<MembershipRevenueItem> get items;
/// Create a copy of MembershipRevenueReportData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipRevenueReportDataCopyWith<MembershipRevenueReportData> get copyWith => _$MembershipRevenueReportDataCopyWithImpl<MembershipRevenueReportData>(this as MembershipRevenueReportData, _$identity);

  /// Serializes this MembershipRevenueReportData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MembershipRevenueReportData&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalMemberships, totalMemberships) || other.totalMemberships == totalMemberships)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,from,to,totalRevenue,totalMemberships,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'MembershipRevenueReportData(from: $from, to: $to, totalRevenue: $totalRevenue, totalMemberships: $totalMemberships, items: $items)';
}


}

/// @nodoc
abstract mixin class $MembershipRevenueReportDataCopyWith<$Res>  {
  factory $MembershipRevenueReportDataCopyWith(MembershipRevenueReportData value, $Res Function(MembershipRevenueReportData) _then) = _$MembershipRevenueReportDataCopyWithImpl;
@useResult
$Res call({
 DateTime from, DateTime to, double totalRevenue, int totalMemberships, List<MembershipRevenueItem> items
});




}
/// @nodoc
class _$MembershipRevenueReportDataCopyWithImpl<$Res>
    implements $MembershipRevenueReportDataCopyWith<$Res> {
  _$MembershipRevenueReportDataCopyWithImpl(this._self, this._then);

  final MembershipRevenueReportData _self;
  final $Res Function(MembershipRevenueReportData) _then;

/// Create a copy of MembershipRevenueReportData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? from = null,Object? to = null,Object? totalRevenue = null,Object? totalMemberships = null,Object? items = null,}) {
  return _then(_self.copyWith(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalMemberships: null == totalMemberships ? _self.totalMemberships : totalMemberships // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MembershipRevenueItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [MembershipRevenueReportData].
extension MembershipRevenueReportDataPatterns on MembershipRevenueReportData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MembershipRevenueReportData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MembershipRevenueReportData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MembershipRevenueReportData value)  $default,){
final _that = this;
switch (_that) {
case _MembershipRevenueReportData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MembershipRevenueReportData value)?  $default,){
final _that = this;
switch (_that) {
case _MembershipRevenueReportData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime from,  DateTime to,  double totalRevenue,  int totalMemberships,  List<MembershipRevenueItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MembershipRevenueReportData() when $default != null:
return $default(_that.from,_that.to,_that.totalRevenue,_that.totalMemberships,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime from,  DateTime to,  double totalRevenue,  int totalMemberships,  List<MembershipRevenueItem> items)  $default,) {final _that = this;
switch (_that) {
case _MembershipRevenueReportData():
return $default(_that.from,_that.to,_that.totalRevenue,_that.totalMemberships,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime from,  DateTime to,  double totalRevenue,  int totalMemberships,  List<MembershipRevenueItem> items)?  $default,) {final _that = this;
switch (_that) {
case _MembershipRevenueReportData() when $default != null:
return $default(_that.from,_that.to,_that.totalRevenue,_that.totalMemberships,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MembershipRevenueReportData implements MembershipRevenueReportData {
  const _MembershipRevenueReportData({required this.from, required this.to, required this.totalRevenue, required this.totalMemberships, final  List<MembershipRevenueItem> items = const []}): _items = items;
  factory _MembershipRevenueReportData.fromJson(Map<String, dynamic> json) => _$MembershipRevenueReportDataFromJson(json);

@override final  DateTime from;
@override final  DateTime to;
@override final  double totalRevenue;
@override final  int totalMemberships;
 final  List<MembershipRevenueItem> _items;
@override@JsonKey() List<MembershipRevenueItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of MembershipRevenueReportData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipRevenueReportDataCopyWith<_MembershipRevenueReportData> get copyWith => __$MembershipRevenueReportDataCopyWithImpl<_MembershipRevenueReportData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembershipRevenueReportDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MembershipRevenueReportData&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalMemberships, totalMemberships) || other.totalMemberships == totalMemberships)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,from,to,totalRevenue,totalMemberships,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'MembershipRevenueReportData(from: $from, to: $to, totalRevenue: $totalRevenue, totalMemberships: $totalMemberships, items: $items)';
}


}

/// @nodoc
abstract mixin class _$MembershipRevenueReportDataCopyWith<$Res> implements $MembershipRevenueReportDataCopyWith<$Res> {
  factory _$MembershipRevenueReportDataCopyWith(_MembershipRevenueReportData value, $Res Function(_MembershipRevenueReportData) _then) = __$MembershipRevenueReportDataCopyWithImpl;
@override @useResult
$Res call({
 DateTime from, DateTime to, double totalRevenue, int totalMemberships, List<MembershipRevenueItem> items
});




}
/// @nodoc
class __$MembershipRevenueReportDataCopyWithImpl<$Res>
    implements _$MembershipRevenueReportDataCopyWith<$Res> {
  __$MembershipRevenueReportDataCopyWithImpl(this._self, this._then);

  final _MembershipRevenueReportData _self;
  final $Res Function(_MembershipRevenueReportData) _then;

/// Create a copy of MembershipRevenueReportData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,Object? totalRevenue = null,Object? totalMemberships = null,Object? items = null,}) {
  return _then(_MembershipRevenueReportData(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,totalMemberships: null == totalMemberships ? _self.totalMemberships : totalMemberships // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MembershipRevenueItem>,
  ));
}


}


/// @nodoc
mixin _$MembershipRevenueItem {

 int get membershipId; String get userName; String get packageName; double get price; DateTime get startDate; DateTime get endDate;
/// Create a copy of MembershipRevenueItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipRevenueItemCopyWith<MembershipRevenueItem> get copyWith => _$MembershipRevenueItemCopyWithImpl<MembershipRevenueItem>(this as MembershipRevenueItem, _$identity);

  /// Serializes this MembershipRevenueItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MembershipRevenueItem&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.price, price) || other.price == price)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,membershipId,userName,packageName,price,startDate,endDate);

@override
String toString() {
  return 'MembershipRevenueItem(membershipId: $membershipId, userName: $userName, packageName: $packageName, price: $price, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $MembershipRevenueItemCopyWith<$Res>  {
  factory $MembershipRevenueItemCopyWith(MembershipRevenueItem value, $Res Function(MembershipRevenueItem) _then) = _$MembershipRevenueItemCopyWithImpl;
@useResult
$Res call({
 int membershipId, String userName, String packageName, double price, DateTime startDate, DateTime endDate
});




}
/// @nodoc
class _$MembershipRevenueItemCopyWithImpl<$Res>
    implements $MembershipRevenueItemCopyWith<$Res> {
  _$MembershipRevenueItemCopyWithImpl(this._self, this._then);

  final MembershipRevenueItem _self;
  final $Res Function(MembershipRevenueItem) _then;

/// Create a copy of MembershipRevenueItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? membershipId = null,Object? userName = null,Object? packageName = null,Object? price = null,Object? startDate = null,Object? endDate = null,}) {
  return _then(_self.copyWith(
membershipId: null == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as int,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MembershipRevenueItem].
extension MembershipRevenueItemPatterns on MembershipRevenueItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MembershipRevenueItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MembershipRevenueItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MembershipRevenueItem value)  $default,){
final _that = this;
switch (_that) {
case _MembershipRevenueItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MembershipRevenueItem value)?  $default,){
final _that = this;
switch (_that) {
case _MembershipRevenueItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int membershipId,  String userName,  String packageName,  double price,  DateTime startDate,  DateTime endDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MembershipRevenueItem() when $default != null:
return $default(_that.membershipId,_that.userName,_that.packageName,_that.price,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int membershipId,  String userName,  String packageName,  double price,  DateTime startDate,  DateTime endDate)  $default,) {final _that = this;
switch (_that) {
case _MembershipRevenueItem():
return $default(_that.membershipId,_that.userName,_that.packageName,_that.price,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int membershipId,  String userName,  String packageName,  double price,  DateTime startDate,  DateTime endDate)?  $default,) {final _that = this;
switch (_that) {
case _MembershipRevenueItem() when $default != null:
return $default(_that.membershipId,_that.userName,_that.packageName,_that.price,_that.startDate,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MembershipRevenueItem implements MembershipRevenueItem {
  const _MembershipRevenueItem({required this.membershipId, required this.userName, required this.packageName, required this.price, required this.startDate, required this.endDate});
  factory _MembershipRevenueItem.fromJson(Map<String, dynamic> json) => _$MembershipRevenueItemFromJson(json);

@override final  int membershipId;
@override final  String userName;
@override final  String packageName;
@override final  double price;
@override final  DateTime startDate;
@override final  DateTime endDate;

/// Create a copy of MembershipRevenueItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipRevenueItemCopyWith<_MembershipRevenueItem> get copyWith => __$MembershipRevenueItemCopyWithImpl<_MembershipRevenueItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembershipRevenueItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MembershipRevenueItem&&(identical(other.membershipId, membershipId) || other.membershipId == membershipId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.price, price) || other.price == price)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,membershipId,userName,packageName,price,startDate,endDate);

@override
String toString() {
  return 'MembershipRevenueItem(membershipId: $membershipId, userName: $userName, packageName: $packageName, price: $price, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$MembershipRevenueItemCopyWith<$Res> implements $MembershipRevenueItemCopyWith<$Res> {
  factory _$MembershipRevenueItemCopyWith(_MembershipRevenueItem value, $Res Function(_MembershipRevenueItem) _then) = __$MembershipRevenueItemCopyWithImpl;
@override @useResult
$Res call({
 int membershipId, String userName, String packageName, double price, DateTime startDate, DateTime endDate
});




}
/// @nodoc
class __$MembershipRevenueItemCopyWithImpl<$Res>
    implements _$MembershipRevenueItemCopyWith<$Res> {
  __$MembershipRevenueItemCopyWithImpl(this._self, this._then);

  final _MembershipRevenueItem _self;
  final $Res Function(_MembershipRevenueItem) _then;

/// Create a copy of MembershipRevenueItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? membershipId = null,Object? userName = null,Object? packageName = null,Object? price = null,Object? startDate = null,Object? endDate = null,}) {
  return _then(_MembershipRevenueItem(
membershipId: null == membershipId ? _self.membershipId : membershipId // ignore: cast_nullable_to_non_nullable
as int,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$UsersReportData {

 DateTime get from; DateTime get to; int get totalNewUsers; List<UserReportItem> get users;
/// Create a copy of UsersReportData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsersReportDataCopyWith<UsersReportData> get copyWith => _$UsersReportDataCopyWithImpl<UsersReportData>(this as UsersReportData, _$identity);

  /// Serializes this UsersReportData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UsersReportData&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.totalNewUsers, totalNewUsers) || other.totalNewUsers == totalNewUsers)&&const DeepCollectionEquality().equals(other.users, users));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,from,to,totalNewUsers,const DeepCollectionEquality().hash(users));

@override
String toString() {
  return 'UsersReportData(from: $from, to: $to, totalNewUsers: $totalNewUsers, users: $users)';
}


}

/// @nodoc
abstract mixin class $UsersReportDataCopyWith<$Res>  {
  factory $UsersReportDataCopyWith(UsersReportData value, $Res Function(UsersReportData) _then) = _$UsersReportDataCopyWithImpl;
@useResult
$Res call({
 DateTime from, DateTime to, int totalNewUsers, List<UserReportItem> users
});




}
/// @nodoc
class _$UsersReportDataCopyWithImpl<$Res>
    implements $UsersReportDataCopyWith<$Res> {
  _$UsersReportDataCopyWithImpl(this._self, this._then);

  final UsersReportData _self;
  final $Res Function(UsersReportData) _then;

/// Create a copy of UsersReportData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? from = null,Object? to = null,Object? totalNewUsers = null,Object? users = null,}) {
  return _then(_self.copyWith(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,totalNewUsers: null == totalNewUsers ? _self.totalNewUsers : totalNewUsers // ignore: cast_nullable_to_non_nullable
as int,users: null == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as List<UserReportItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [UsersReportData].
extension UsersReportDataPatterns on UsersReportData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UsersReportData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UsersReportData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UsersReportData value)  $default,){
final _that = this;
switch (_that) {
case _UsersReportData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UsersReportData value)?  $default,){
final _that = this;
switch (_that) {
case _UsersReportData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime from,  DateTime to,  int totalNewUsers,  List<UserReportItem> users)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UsersReportData() when $default != null:
return $default(_that.from,_that.to,_that.totalNewUsers,_that.users);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime from,  DateTime to,  int totalNewUsers,  List<UserReportItem> users)  $default,) {final _that = this;
switch (_that) {
case _UsersReportData():
return $default(_that.from,_that.to,_that.totalNewUsers,_that.users);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime from,  DateTime to,  int totalNewUsers,  List<UserReportItem> users)?  $default,) {final _that = this;
switch (_that) {
case _UsersReportData() when $default != null:
return $default(_that.from,_that.to,_that.totalNewUsers,_that.users);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UsersReportData implements UsersReportData {
  const _UsersReportData({required this.from, required this.to, required this.totalNewUsers, final  List<UserReportItem> users = const []}): _users = users;
  factory _UsersReportData.fromJson(Map<String, dynamic> json) => _$UsersReportDataFromJson(json);

@override final  DateTime from;
@override final  DateTime to;
@override final  int totalNewUsers;
 final  List<UserReportItem> _users;
@override@JsonKey() List<UserReportItem> get users {
  if (_users is EqualUnmodifiableListView) return _users;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_users);
}


/// Create a copy of UsersReportData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsersReportDataCopyWith<_UsersReportData> get copyWith => __$UsersReportDataCopyWithImpl<_UsersReportData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UsersReportDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UsersReportData&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.totalNewUsers, totalNewUsers) || other.totalNewUsers == totalNewUsers)&&const DeepCollectionEquality().equals(other._users, _users));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,from,to,totalNewUsers,const DeepCollectionEquality().hash(_users));

@override
String toString() {
  return 'UsersReportData(from: $from, to: $to, totalNewUsers: $totalNewUsers, users: $users)';
}


}

/// @nodoc
abstract mixin class _$UsersReportDataCopyWith<$Res> implements $UsersReportDataCopyWith<$Res> {
  factory _$UsersReportDataCopyWith(_UsersReportData value, $Res Function(_UsersReportData) _then) = __$UsersReportDataCopyWithImpl;
@override @useResult
$Res call({
 DateTime from, DateTime to, int totalNewUsers, List<UserReportItem> users
});




}
/// @nodoc
class __$UsersReportDataCopyWithImpl<$Res>
    implements _$UsersReportDataCopyWith<$Res> {
  __$UsersReportDataCopyWithImpl(this._self, this._then);

  final _UsersReportData _self;
  final $Res Function(_UsersReportData) _then;

/// Create a copy of UsersReportData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,Object? totalNewUsers = null,Object? users = null,}) {
  return _then(_UsersReportData(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,totalNewUsers: null == totalNewUsers ? _self.totalNewUsers : totalNewUsers // ignore: cast_nullable_to_non_nullable
as int,users: null == users ? _self._users : users // ignore: cast_nullable_to_non_nullable
as List<UserReportItem>,
  ));
}


}


/// @nodoc
mixin _$UserReportItem {

 int get id; String get fullName; String get email; DateTime get createdAt;
/// Create a copy of UserReportItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserReportItemCopyWith<UserReportItem> get copyWith => _$UserReportItemCopyWithImpl<UserReportItem>(this as UserReportItem, _$identity);

  /// Serializes this UserReportItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserReportItem&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,createdAt);

@override
String toString() {
  return 'UserReportItem(id: $id, fullName: $fullName, email: $email, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $UserReportItemCopyWith<$Res>  {
  factory $UserReportItemCopyWith(UserReportItem value, $Res Function(UserReportItem) _then) = _$UserReportItemCopyWithImpl;
@useResult
$Res call({
 int id, String fullName, String email, DateTime createdAt
});




}
/// @nodoc
class _$UserReportItemCopyWithImpl<$Res>
    implements $UserReportItemCopyWith<$Res> {
  _$UserReportItemCopyWithImpl(this._self, this._then);

  final UserReportItem _self;
  final $Res Function(UserReportItem) _then;

/// Create a copy of UserReportItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UserReportItem].
extension UserReportItemPatterns on UserReportItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserReportItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserReportItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserReportItem value)  $default,){
final _that = this;
switch (_that) {
case _UserReportItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserReportItem value)?  $default,){
final _that = this;
switch (_that) {
case _UserReportItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String fullName,  String email,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserReportItem() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String fullName,  String email,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _UserReportItem():
return $default(_that.id,_that.fullName,_that.email,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String fullName,  String email,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _UserReportItem() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserReportItem implements UserReportItem {
  const _UserReportItem({required this.id, required this.fullName, required this.email, required this.createdAt});
  factory _UserReportItem.fromJson(Map<String, dynamic> json) => _$UserReportItemFromJson(json);

@override final  int id;
@override final  String fullName;
@override final  String email;
@override final  DateTime createdAt;

/// Create a copy of UserReportItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserReportItemCopyWith<_UserReportItem> get copyWith => __$UserReportItemCopyWithImpl<_UserReportItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserReportItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserReportItem&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,email,createdAt);

@override
String toString() {
  return 'UserReportItem(id: $id, fullName: $fullName, email: $email, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserReportItemCopyWith<$Res> implements $UserReportItemCopyWith<$Res> {
  factory _$UserReportItemCopyWith(_UserReportItem value, $Res Function(_UserReportItem) _then) = __$UserReportItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String fullName, String email, DateTime createdAt
});




}
/// @nodoc
class __$UserReportItemCopyWithImpl<$Res>
    implements _$UserReportItemCopyWith<$Res> {
  __$UserReportItemCopyWithImpl(this._self, this._then);

  final _UserReportItem _self;
  final $Res Function(_UserReportItem) _then;

/// Create a copy of UserReportItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? email = null,Object? createdAt = null,}) {
  return _then(_UserReportItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ProductsReportData {

 DateTime get from; DateTime get to; List<TopSellingProductItem> get topSelling; List<StockLevelItem> get stockLevels;
/// Create a copy of ProductsReportData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsReportDataCopyWith<ProductsReportData> get copyWith => _$ProductsReportDataCopyWithImpl<ProductsReportData>(this as ProductsReportData, _$identity);

  /// Serializes this ProductsReportData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsReportData&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&const DeepCollectionEquality().equals(other.topSelling, topSelling)&&const DeepCollectionEquality().equals(other.stockLevels, stockLevels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,from,to,const DeepCollectionEquality().hash(topSelling),const DeepCollectionEquality().hash(stockLevels));

@override
String toString() {
  return 'ProductsReportData(from: $from, to: $to, topSelling: $topSelling, stockLevels: $stockLevels)';
}


}

/// @nodoc
abstract mixin class $ProductsReportDataCopyWith<$Res>  {
  factory $ProductsReportDataCopyWith(ProductsReportData value, $Res Function(ProductsReportData) _then) = _$ProductsReportDataCopyWithImpl;
@useResult
$Res call({
 DateTime from, DateTime to, List<TopSellingProductItem> topSelling, List<StockLevelItem> stockLevels
});




}
/// @nodoc
class _$ProductsReportDataCopyWithImpl<$Res>
    implements $ProductsReportDataCopyWith<$Res> {
  _$ProductsReportDataCopyWithImpl(this._self, this._then);

  final ProductsReportData _self;
  final $Res Function(ProductsReportData) _then;

/// Create a copy of ProductsReportData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? from = null,Object? to = null,Object? topSelling = null,Object? stockLevels = null,}) {
  return _then(_self.copyWith(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,topSelling: null == topSelling ? _self.topSelling : topSelling // ignore: cast_nullable_to_non_nullable
as List<TopSellingProductItem>,stockLevels: null == stockLevels ? _self.stockLevels : stockLevels // ignore: cast_nullable_to_non_nullable
as List<StockLevelItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductsReportData].
extension ProductsReportDataPatterns on ProductsReportData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductsReportData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductsReportData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductsReportData value)  $default,){
final _that = this;
switch (_that) {
case _ProductsReportData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductsReportData value)?  $default,){
final _that = this;
switch (_that) {
case _ProductsReportData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime from,  DateTime to,  List<TopSellingProductItem> topSelling,  List<StockLevelItem> stockLevels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductsReportData() when $default != null:
return $default(_that.from,_that.to,_that.topSelling,_that.stockLevels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime from,  DateTime to,  List<TopSellingProductItem> topSelling,  List<StockLevelItem> stockLevels)  $default,) {final _that = this;
switch (_that) {
case _ProductsReportData():
return $default(_that.from,_that.to,_that.topSelling,_that.stockLevels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime from,  DateTime to,  List<TopSellingProductItem> topSelling,  List<StockLevelItem> stockLevels)?  $default,) {final _that = this;
switch (_that) {
case _ProductsReportData() when $default != null:
return $default(_that.from,_that.to,_that.topSelling,_that.stockLevels);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductsReportData implements ProductsReportData {
  const _ProductsReportData({required this.from, required this.to, final  List<TopSellingProductItem> topSelling = const [], final  List<StockLevelItem> stockLevels = const []}): _topSelling = topSelling,_stockLevels = stockLevels;
  factory _ProductsReportData.fromJson(Map<String, dynamic> json) => _$ProductsReportDataFromJson(json);

@override final  DateTime from;
@override final  DateTime to;
 final  List<TopSellingProductItem> _topSelling;
@override@JsonKey() List<TopSellingProductItem> get topSelling {
  if (_topSelling is EqualUnmodifiableListView) return _topSelling;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topSelling);
}

 final  List<StockLevelItem> _stockLevels;
@override@JsonKey() List<StockLevelItem> get stockLevels {
  if (_stockLevels is EqualUnmodifiableListView) return _stockLevels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stockLevels);
}


/// Create a copy of ProductsReportData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductsReportDataCopyWith<_ProductsReportData> get copyWith => __$ProductsReportDataCopyWithImpl<_ProductsReportData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductsReportDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductsReportData&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&const DeepCollectionEquality().equals(other._topSelling, _topSelling)&&const DeepCollectionEquality().equals(other._stockLevels, _stockLevels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,from,to,const DeepCollectionEquality().hash(_topSelling),const DeepCollectionEquality().hash(_stockLevels));

@override
String toString() {
  return 'ProductsReportData(from: $from, to: $to, topSelling: $topSelling, stockLevels: $stockLevels)';
}


}

/// @nodoc
abstract mixin class _$ProductsReportDataCopyWith<$Res> implements $ProductsReportDataCopyWith<$Res> {
  factory _$ProductsReportDataCopyWith(_ProductsReportData value, $Res Function(_ProductsReportData) _then) = __$ProductsReportDataCopyWithImpl;
@override @useResult
$Res call({
 DateTime from, DateTime to, List<TopSellingProductItem> topSelling, List<StockLevelItem> stockLevels
});




}
/// @nodoc
class __$ProductsReportDataCopyWithImpl<$Res>
    implements _$ProductsReportDataCopyWith<$Res> {
  __$ProductsReportDataCopyWithImpl(this._self, this._then);

  final _ProductsReportData _self;
  final $Res Function(_ProductsReportData) _then;

/// Create a copy of ProductsReportData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,Object? topSelling = null,Object? stockLevels = null,}) {
  return _then(_ProductsReportData(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,topSelling: null == topSelling ? _self._topSelling : topSelling // ignore: cast_nullable_to_non_nullable
as List<TopSellingProductItem>,stockLevels: null == stockLevels ? _self._stockLevels : stockLevels // ignore: cast_nullable_to_non_nullable
as List<StockLevelItem>,
  ));
}


}


/// @nodoc
mixin _$TopSellingProductItem {

 int get productId; String get productName; String get categoryName; int get totalQuantitySold; double get totalRevenue;
/// Create a copy of TopSellingProductItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopSellingProductItemCopyWith<TopSellingProductItem> get copyWith => _$TopSellingProductItemCopyWithImpl<TopSellingProductItem>(this as TopSellingProductItem, _$identity);

  /// Serializes this TopSellingProductItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TopSellingProductItem&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.totalQuantitySold, totalQuantitySold) || other.totalQuantitySold == totalQuantitySold)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,productName,categoryName,totalQuantitySold,totalRevenue);

@override
String toString() {
  return 'TopSellingProductItem(productId: $productId, productName: $productName, categoryName: $categoryName, totalQuantitySold: $totalQuantitySold, totalRevenue: $totalRevenue)';
}


}

/// @nodoc
abstract mixin class $TopSellingProductItemCopyWith<$Res>  {
  factory $TopSellingProductItemCopyWith(TopSellingProductItem value, $Res Function(TopSellingProductItem) _then) = _$TopSellingProductItemCopyWithImpl;
@useResult
$Res call({
 int productId, String productName, String categoryName, int totalQuantitySold, double totalRevenue
});




}
/// @nodoc
class _$TopSellingProductItemCopyWithImpl<$Res>
    implements $TopSellingProductItemCopyWith<$Res> {
  _$TopSellingProductItemCopyWithImpl(this._self, this._then);

  final TopSellingProductItem _self;
  final $Res Function(TopSellingProductItem) _then;

/// Create a copy of TopSellingProductItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? productName = null,Object? categoryName = null,Object? totalQuantitySold = null,Object? totalRevenue = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,totalQuantitySold: null == totalQuantitySold ? _self.totalQuantitySold : totalQuantitySold // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TopSellingProductItem].
extension TopSellingProductItemPatterns on TopSellingProductItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TopSellingProductItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TopSellingProductItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TopSellingProductItem value)  $default,){
final _that = this;
switch (_that) {
case _TopSellingProductItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TopSellingProductItem value)?  $default,){
final _that = this;
switch (_that) {
case _TopSellingProductItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  String productName,  String categoryName,  int totalQuantitySold,  double totalRevenue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TopSellingProductItem() when $default != null:
return $default(_that.productId,_that.productName,_that.categoryName,_that.totalQuantitySold,_that.totalRevenue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  String productName,  String categoryName,  int totalQuantitySold,  double totalRevenue)  $default,) {final _that = this;
switch (_that) {
case _TopSellingProductItem():
return $default(_that.productId,_that.productName,_that.categoryName,_that.totalQuantitySold,_that.totalRevenue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  String productName,  String categoryName,  int totalQuantitySold,  double totalRevenue)?  $default,) {final _that = this;
switch (_that) {
case _TopSellingProductItem() when $default != null:
return $default(_that.productId,_that.productName,_that.categoryName,_that.totalQuantitySold,_that.totalRevenue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TopSellingProductItem implements TopSellingProductItem {
  const _TopSellingProductItem({required this.productId, required this.productName, required this.categoryName, required this.totalQuantitySold, required this.totalRevenue});
  factory _TopSellingProductItem.fromJson(Map<String, dynamic> json) => _$TopSellingProductItemFromJson(json);

@override final  int productId;
@override final  String productName;
@override final  String categoryName;
@override final  int totalQuantitySold;
@override final  double totalRevenue;

/// Create a copy of TopSellingProductItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopSellingProductItemCopyWith<_TopSellingProductItem> get copyWith => __$TopSellingProductItemCopyWithImpl<_TopSellingProductItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TopSellingProductItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TopSellingProductItem&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.totalQuantitySold, totalQuantitySold) || other.totalQuantitySold == totalQuantitySold)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,productName,categoryName,totalQuantitySold,totalRevenue);

@override
String toString() {
  return 'TopSellingProductItem(productId: $productId, productName: $productName, categoryName: $categoryName, totalQuantitySold: $totalQuantitySold, totalRevenue: $totalRevenue)';
}


}

/// @nodoc
abstract mixin class _$TopSellingProductItemCopyWith<$Res> implements $TopSellingProductItemCopyWith<$Res> {
  factory _$TopSellingProductItemCopyWith(_TopSellingProductItem value, $Res Function(_TopSellingProductItem) _then) = __$TopSellingProductItemCopyWithImpl;
@override @useResult
$Res call({
 int productId, String productName, String categoryName, int totalQuantitySold, double totalRevenue
});




}
/// @nodoc
class __$TopSellingProductItemCopyWithImpl<$Res>
    implements _$TopSellingProductItemCopyWith<$Res> {
  __$TopSellingProductItemCopyWithImpl(this._self, this._then);

  final _TopSellingProductItem _self;
  final $Res Function(_TopSellingProductItem) _then;

/// Create a copy of TopSellingProductItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? productName = null,Object? categoryName = null,Object? totalQuantitySold = null,Object? totalRevenue = null,}) {
  return _then(_TopSellingProductItem(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,totalQuantitySold: null == totalQuantitySold ? _self.totalQuantitySold : totalQuantitySold // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$StockLevelItem {

 int get productId; String get productName; String get categoryName; int get stockQuantity; double get price;
/// Create a copy of StockLevelItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockLevelItemCopyWith<StockLevelItem> get copyWith => _$StockLevelItemCopyWithImpl<StockLevelItem>(this as StockLevelItem, _$identity);

  /// Serializes this StockLevelItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockLevelItem&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.stockQuantity, stockQuantity) || other.stockQuantity == stockQuantity)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,productName,categoryName,stockQuantity,price);

@override
String toString() {
  return 'StockLevelItem(productId: $productId, productName: $productName, categoryName: $categoryName, stockQuantity: $stockQuantity, price: $price)';
}


}

/// @nodoc
abstract mixin class $StockLevelItemCopyWith<$Res>  {
  factory $StockLevelItemCopyWith(StockLevelItem value, $Res Function(StockLevelItem) _then) = _$StockLevelItemCopyWithImpl;
@useResult
$Res call({
 int productId, String productName, String categoryName, int stockQuantity, double price
});




}
/// @nodoc
class _$StockLevelItemCopyWithImpl<$Res>
    implements $StockLevelItemCopyWith<$Res> {
  _$StockLevelItemCopyWithImpl(this._self, this._then);

  final StockLevelItem _self;
  final $Res Function(StockLevelItem) _then;

/// Create a copy of StockLevelItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? productName = null,Object? categoryName = null,Object? stockQuantity = null,Object? price = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,stockQuantity: null == stockQuantity ? _self.stockQuantity : stockQuantity // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [StockLevelItem].
extension StockLevelItemPatterns on StockLevelItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockLevelItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockLevelItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockLevelItem value)  $default,){
final _that = this;
switch (_that) {
case _StockLevelItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockLevelItem value)?  $default,){
final _that = this;
switch (_that) {
case _StockLevelItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int productId,  String productName,  String categoryName,  int stockQuantity,  double price)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockLevelItem() when $default != null:
return $default(_that.productId,_that.productName,_that.categoryName,_that.stockQuantity,_that.price);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int productId,  String productName,  String categoryName,  int stockQuantity,  double price)  $default,) {final _that = this;
switch (_that) {
case _StockLevelItem():
return $default(_that.productId,_that.productName,_that.categoryName,_that.stockQuantity,_that.price);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int productId,  String productName,  String categoryName,  int stockQuantity,  double price)?  $default,) {final _that = this;
switch (_that) {
case _StockLevelItem() when $default != null:
return $default(_that.productId,_that.productName,_that.categoryName,_that.stockQuantity,_that.price);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StockLevelItem implements StockLevelItem {
  const _StockLevelItem({required this.productId, required this.productName, required this.categoryName, required this.stockQuantity, required this.price});
  factory _StockLevelItem.fromJson(Map<String, dynamic> json) => _$StockLevelItemFromJson(json);

@override final  int productId;
@override final  String productName;
@override final  String categoryName;
@override final  int stockQuantity;
@override final  double price;

/// Create a copy of StockLevelItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockLevelItemCopyWith<_StockLevelItem> get copyWith => __$StockLevelItemCopyWithImpl<_StockLevelItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StockLevelItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockLevelItem&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.stockQuantity, stockQuantity) || other.stockQuantity == stockQuantity)&&(identical(other.price, price) || other.price == price));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,productName,categoryName,stockQuantity,price);

@override
String toString() {
  return 'StockLevelItem(productId: $productId, productName: $productName, categoryName: $categoryName, stockQuantity: $stockQuantity, price: $price)';
}


}

/// @nodoc
abstract mixin class _$StockLevelItemCopyWith<$Res> implements $StockLevelItemCopyWith<$Res> {
  factory _$StockLevelItemCopyWith(_StockLevelItem value, $Res Function(_StockLevelItem) _then) = __$StockLevelItemCopyWithImpl;
@override @useResult
$Res call({
 int productId, String productName, String categoryName, int stockQuantity, double price
});




}
/// @nodoc
class __$StockLevelItemCopyWithImpl<$Res>
    implements _$StockLevelItemCopyWith<$Res> {
  __$StockLevelItemCopyWithImpl(this._self, this._then);

  final _StockLevelItem _self;
  final $Res Function(_StockLevelItem) _then;

/// Create a copy of StockLevelItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? productName = null,Object? categoryName = null,Object? stockQuantity = null,Object? price = null,}) {
  return _then(_StockLevelItem(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,stockQuantity: null == stockQuantity ? _self.stockQuantity : stockQuantity // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$AppointmentsReportData {

 DateTime get from; DateTime get to; int get totalAppointments; List<StaffAppointmentItem> get staffStats;
/// Create a copy of AppointmentsReportData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppointmentsReportDataCopyWith<AppointmentsReportData> get copyWith => _$AppointmentsReportDataCopyWithImpl<AppointmentsReportData>(this as AppointmentsReportData, _$identity);

  /// Serializes this AppointmentsReportData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppointmentsReportData&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.totalAppointments, totalAppointments) || other.totalAppointments == totalAppointments)&&const DeepCollectionEquality().equals(other.staffStats, staffStats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,from,to,totalAppointments,const DeepCollectionEquality().hash(staffStats));

@override
String toString() {
  return 'AppointmentsReportData(from: $from, to: $to, totalAppointments: $totalAppointments, staffStats: $staffStats)';
}


}

/// @nodoc
abstract mixin class $AppointmentsReportDataCopyWith<$Res>  {
  factory $AppointmentsReportDataCopyWith(AppointmentsReportData value, $Res Function(AppointmentsReportData) _then) = _$AppointmentsReportDataCopyWithImpl;
@useResult
$Res call({
 DateTime from, DateTime to, int totalAppointments, List<StaffAppointmentItem> staffStats
});




}
/// @nodoc
class _$AppointmentsReportDataCopyWithImpl<$Res>
    implements $AppointmentsReportDataCopyWith<$Res> {
  _$AppointmentsReportDataCopyWithImpl(this._self, this._then);

  final AppointmentsReportData _self;
  final $Res Function(AppointmentsReportData) _then;

/// Create a copy of AppointmentsReportData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? from = null,Object? to = null,Object? totalAppointments = null,Object? staffStats = null,}) {
  return _then(_self.copyWith(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,totalAppointments: null == totalAppointments ? _self.totalAppointments : totalAppointments // ignore: cast_nullable_to_non_nullable
as int,staffStats: null == staffStats ? _self.staffStats : staffStats // ignore: cast_nullable_to_non_nullable
as List<StaffAppointmentItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [AppointmentsReportData].
extension AppointmentsReportDataPatterns on AppointmentsReportData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppointmentsReportData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppointmentsReportData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppointmentsReportData value)  $default,){
final _that = this;
switch (_that) {
case _AppointmentsReportData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppointmentsReportData value)?  $default,){
final _that = this;
switch (_that) {
case _AppointmentsReportData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime from,  DateTime to,  int totalAppointments,  List<StaffAppointmentItem> staffStats)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppointmentsReportData() when $default != null:
return $default(_that.from,_that.to,_that.totalAppointments,_that.staffStats);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime from,  DateTime to,  int totalAppointments,  List<StaffAppointmentItem> staffStats)  $default,) {final _that = this;
switch (_that) {
case _AppointmentsReportData():
return $default(_that.from,_that.to,_that.totalAppointments,_that.staffStats);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime from,  DateTime to,  int totalAppointments,  List<StaffAppointmentItem> staffStats)?  $default,) {final _that = this;
switch (_that) {
case _AppointmentsReportData() when $default != null:
return $default(_that.from,_that.to,_that.totalAppointments,_that.staffStats);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppointmentsReportData implements AppointmentsReportData {
  const _AppointmentsReportData({required this.from, required this.to, required this.totalAppointments, final  List<StaffAppointmentItem> staffStats = const []}): _staffStats = staffStats;
  factory _AppointmentsReportData.fromJson(Map<String, dynamic> json) => _$AppointmentsReportDataFromJson(json);

@override final  DateTime from;
@override final  DateTime to;
@override final  int totalAppointments;
 final  List<StaffAppointmentItem> _staffStats;
@override@JsonKey() List<StaffAppointmentItem> get staffStats {
  if (_staffStats is EqualUnmodifiableListView) return _staffStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_staffStats);
}


/// Create a copy of AppointmentsReportData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppointmentsReportDataCopyWith<_AppointmentsReportData> get copyWith => __$AppointmentsReportDataCopyWithImpl<_AppointmentsReportData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppointmentsReportDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppointmentsReportData&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.totalAppointments, totalAppointments) || other.totalAppointments == totalAppointments)&&const DeepCollectionEquality().equals(other._staffStats, _staffStats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,from,to,totalAppointments,const DeepCollectionEquality().hash(_staffStats));

@override
String toString() {
  return 'AppointmentsReportData(from: $from, to: $to, totalAppointments: $totalAppointments, staffStats: $staffStats)';
}


}

/// @nodoc
abstract mixin class _$AppointmentsReportDataCopyWith<$Res> implements $AppointmentsReportDataCopyWith<$Res> {
  factory _$AppointmentsReportDataCopyWith(_AppointmentsReportData value, $Res Function(_AppointmentsReportData) _then) = __$AppointmentsReportDataCopyWithImpl;
@override @useResult
$Res call({
 DateTime from, DateTime to, int totalAppointments, List<StaffAppointmentItem> staffStats
});




}
/// @nodoc
class __$AppointmentsReportDataCopyWithImpl<$Res>
    implements _$AppointmentsReportDataCopyWith<$Res> {
  __$AppointmentsReportDataCopyWithImpl(this._self, this._then);

  final _AppointmentsReportData _self;
  final $Res Function(_AppointmentsReportData) _then;

/// Create a copy of AppointmentsReportData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,Object? totalAppointments = null,Object? staffStats = null,}) {
  return _then(_AppointmentsReportData(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,totalAppointments: null == totalAppointments ? _self.totalAppointments : totalAppointments // ignore: cast_nullable_to_non_nullable
as int,staffStats: null == staffStats ? _self._staffStats : staffStats // ignore: cast_nullable_to_non_nullable
as List<StaffAppointmentItem>,
  ));
}


}


/// @nodoc
mixin _$StaffAppointmentItem {

 int get staffId; String get staffName; String get staffType; int get totalAppointments; int get completed; int get approved; int get rejected; int get pending;
/// Create a copy of StaffAppointmentItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffAppointmentItemCopyWith<StaffAppointmentItem> get copyWith => _$StaffAppointmentItemCopyWithImpl<StaffAppointmentItem>(this as StaffAppointmentItem, _$identity);

  /// Serializes this StaffAppointmentItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffAppointmentItem&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.staffName, staffName) || other.staffName == staffName)&&(identical(other.staffType, staffType) || other.staffType == staffType)&&(identical(other.totalAppointments, totalAppointments) || other.totalAppointments == totalAppointments)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.approved, approved) || other.approved == approved)&&(identical(other.rejected, rejected) || other.rejected == rejected)&&(identical(other.pending, pending) || other.pending == pending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,staffId,staffName,staffType,totalAppointments,completed,approved,rejected,pending);

@override
String toString() {
  return 'StaffAppointmentItem(staffId: $staffId, staffName: $staffName, staffType: $staffType, totalAppointments: $totalAppointments, completed: $completed, approved: $approved, rejected: $rejected, pending: $pending)';
}


}

/// @nodoc
abstract mixin class $StaffAppointmentItemCopyWith<$Res>  {
  factory $StaffAppointmentItemCopyWith(StaffAppointmentItem value, $Res Function(StaffAppointmentItem) _then) = _$StaffAppointmentItemCopyWithImpl;
@useResult
$Res call({
 int staffId, String staffName, String staffType, int totalAppointments, int completed, int approved, int rejected, int pending
});




}
/// @nodoc
class _$StaffAppointmentItemCopyWithImpl<$Res>
    implements $StaffAppointmentItemCopyWith<$Res> {
  _$StaffAppointmentItemCopyWithImpl(this._self, this._then);

  final StaffAppointmentItem _self;
  final $Res Function(StaffAppointmentItem) _then;

/// Create a copy of StaffAppointmentItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? staffId = null,Object? staffName = null,Object? staffType = null,Object? totalAppointments = null,Object? completed = null,Object? approved = null,Object? rejected = null,Object? pending = null,}) {
  return _then(_self.copyWith(
staffId: null == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as int,staffName: null == staffName ? _self.staffName : staffName // ignore: cast_nullable_to_non_nullable
as String,staffType: null == staffType ? _self.staffType : staffType // ignore: cast_nullable_to_non_nullable
as String,totalAppointments: null == totalAppointments ? _self.totalAppointments : totalAppointments // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,approved: null == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffAppointmentItem].
extension StaffAppointmentItemPatterns on StaffAppointmentItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffAppointmentItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffAppointmentItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffAppointmentItem value)  $default,){
final _that = this;
switch (_that) {
case _StaffAppointmentItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffAppointmentItem value)?  $default,){
final _that = this;
switch (_that) {
case _StaffAppointmentItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int staffId,  String staffName,  String staffType,  int totalAppointments,  int completed,  int approved,  int rejected,  int pending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffAppointmentItem() when $default != null:
return $default(_that.staffId,_that.staffName,_that.staffType,_that.totalAppointments,_that.completed,_that.approved,_that.rejected,_that.pending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int staffId,  String staffName,  String staffType,  int totalAppointments,  int completed,  int approved,  int rejected,  int pending)  $default,) {final _that = this;
switch (_that) {
case _StaffAppointmentItem():
return $default(_that.staffId,_that.staffName,_that.staffType,_that.totalAppointments,_that.completed,_that.approved,_that.rejected,_that.pending);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int staffId,  String staffName,  String staffType,  int totalAppointments,  int completed,  int approved,  int rejected,  int pending)?  $default,) {final _that = this;
switch (_that) {
case _StaffAppointmentItem() when $default != null:
return $default(_that.staffId,_that.staffName,_that.staffType,_that.totalAppointments,_that.completed,_that.approved,_that.rejected,_that.pending);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffAppointmentItem implements StaffAppointmentItem {
  const _StaffAppointmentItem({required this.staffId, required this.staffName, required this.staffType, required this.totalAppointments, required this.completed, required this.approved, required this.rejected, required this.pending});
  factory _StaffAppointmentItem.fromJson(Map<String, dynamic> json) => _$StaffAppointmentItemFromJson(json);

@override final  int staffId;
@override final  String staffName;
@override final  String staffType;
@override final  int totalAppointments;
@override final  int completed;
@override final  int approved;
@override final  int rejected;
@override final  int pending;

/// Create a copy of StaffAppointmentItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffAppointmentItemCopyWith<_StaffAppointmentItem> get copyWith => __$StaffAppointmentItemCopyWithImpl<_StaffAppointmentItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffAppointmentItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffAppointmentItem&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.staffName, staffName) || other.staffName == staffName)&&(identical(other.staffType, staffType) || other.staffType == staffType)&&(identical(other.totalAppointments, totalAppointments) || other.totalAppointments == totalAppointments)&&(identical(other.completed, completed) || other.completed == completed)&&(identical(other.approved, approved) || other.approved == approved)&&(identical(other.rejected, rejected) || other.rejected == rejected)&&(identical(other.pending, pending) || other.pending == pending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,staffId,staffName,staffType,totalAppointments,completed,approved,rejected,pending);

@override
String toString() {
  return 'StaffAppointmentItem(staffId: $staffId, staffName: $staffName, staffType: $staffType, totalAppointments: $totalAppointments, completed: $completed, approved: $approved, rejected: $rejected, pending: $pending)';
}


}

/// @nodoc
abstract mixin class _$StaffAppointmentItemCopyWith<$Res> implements $StaffAppointmentItemCopyWith<$Res> {
  factory _$StaffAppointmentItemCopyWith(_StaffAppointmentItem value, $Res Function(_StaffAppointmentItem) _then) = __$StaffAppointmentItemCopyWithImpl;
@override @useResult
$Res call({
 int staffId, String staffName, String staffType, int totalAppointments, int completed, int approved, int rejected, int pending
});




}
/// @nodoc
class __$StaffAppointmentItemCopyWithImpl<$Res>
    implements _$StaffAppointmentItemCopyWith<$Res> {
  __$StaffAppointmentItemCopyWithImpl(this._self, this._then);

  final _StaffAppointmentItem _self;
  final $Res Function(_StaffAppointmentItem) _then;

/// Create a copy of StaffAppointmentItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? staffId = null,Object? staffName = null,Object? staffType = null,Object? totalAppointments = null,Object? completed = null,Object? approved = null,Object? rejected = null,Object? pending = null,}) {
  return _then(_StaffAppointmentItem(
staffId: null == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as int,staffName: null == staffName ? _self.staffName : staffName // ignore: cast_nullable_to_non_nullable
as String,staffType: null == staffType ? _self.staffType : staffType // ignore: cast_nullable_to_non_nullable
as String,totalAppointments: null == totalAppointments ? _self.totalAppointments : totalAppointments // ignore: cast_nullable_to_non_nullable
as int,completed: null == completed ? _self.completed : completed // ignore: cast_nullable_to_non_nullable
as int,approved: null == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
