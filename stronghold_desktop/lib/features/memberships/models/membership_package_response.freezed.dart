// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership_package_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MembershipPackageResponse {

 int get id; String get name; String? get description; double get price; DateTime get createdAt;
/// Create a copy of MembershipPackageResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipPackageResponseCopyWith<MembershipPackageResponse> get copyWith => _$MembershipPackageResponseCopyWithImpl<MembershipPackageResponse>(this as MembershipPackageResponse, _$identity);

  /// Serializes this MembershipPackageResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MembershipPackageResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,price,createdAt);

@override
String toString() {
  return 'MembershipPackageResponse(id: $id, name: $name, description: $description, price: $price, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MembershipPackageResponseCopyWith<$Res>  {
  factory $MembershipPackageResponseCopyWith(MembershipPackageResponse value, $Res Function(MembershipPackageResponse) _then) = _$MembershipPackageResponseCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? description, double price, DateTime createdAt
});




}
/// @nodoc
class _$MembershipPackageResponseCopyWithImpl<$Res>
    implements $MembershipPackageResponseCopyWith<$Res> {
  _$MembershipPackageResponseCopyWithImpl(this._self, this._then);

  final MembershipPackageResponse _self;
  final $Res Function(MembershipPackageResponse) _then;

/// Create a copy of MembershipPackageResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? price = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MembershipPackageResponse].
extension MembershipPackageResponsePatterns on MembershipPackageResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MembershipPackageResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MembershipPackageResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MembershipPackageResponse value)  $default,){
final _that = this;
switch (_that) {
case _MembershipPackageResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MembershipPackageResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MembershipPackageResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? description,  double price,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MembershipPackageResponse() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.price,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? description,  double price,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _MembershipPackageResponse():
return $default(_that.id,_that.name,_that.description,_that.price,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? description,  double price,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MembershipPackageResponse() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.price,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MembershipPackageResponse implements MembershipPackageResponse {
  const _MembershipPackageResponse({required this.id, required this.name, this.description, required this.price, required this.createdAt});
  factory _MembershipPackageResponse.fromJson(Map<String, dynamic> json) => _$MembershipPackageResponseFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? description;
@override final  double price;
@override final  DateTime createdAt;

/// Create a copy of MembershipPackageResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipPackageResponseCopyWith<_MembershipPackageResponse> get copyWith => __$MembershipPackageResponseCopyWithImpl<_MembershipPackageResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembershipPackageResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MembershipPackageResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.price, price) || other.price == price)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,price,createdAt);

@override
String toString() {
  return 'MembershipPackageResponse(id: $id, name: $name, description: $description, price: $price, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MembershipPackageResponseCopyWith<$Res> implements $MembershipPackageResponseCopyWith<$Res> {
  factory _$MembershipPackageResponseCopyWith(_MembershipPackageResponse value, $Res Function(_MembershipPackageResponse) _then) = __$MembershipPackageResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? description, double price, DateTime createdAt
});




}
/// @nodoc
class __$MembershipPackageResponseCopyWithImpl<$Res>
    implements _$MembershipPackageResponseCopyWith<$Res> {
  __$MembershipPackageResponseCopyWithImpl(this._self, this._then);

  final _MembershipPackageResponse _self;
  final $Res Function(_MembershipPackageResponse) _then;

/// Create a copy of MembershipPackageResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? price = null,Object? createdAt = null,}) {
  return _then(_MembershipPackageResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$PagedMembershipPackageResponse {

 List<MembershipPackageResponse> get items; int get totalCount; int get totalPages; int get currentPage; int get pageSize;
/// Create a copy of PagedMembershipPackageResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagedMembershipPackageResponseCopyWith<PagedMembershipPackageResponse> get copyWith => _$PagedMembershipPackageResponseCopyWithImpl<PagedMembershipPackageResponse>(this as PagedMembershipPackageResponse, _$identity);

  /// Serializes this PagedMembershipPackageResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagedMembershipPackageResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedMembershipPackageResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class $PagedMembershipPackageResponseCopyWith<$Res>  {
  factory $PagedMembershipPackageResponseCopyWith(PagedMembershipPackageResponse value, $Res Function(PagedMembershipPackageResponse) _then) = _$PagedMembershipPackageResponseCopyWithImpl;
@useResult
$Res call({
 List<MembershipPackageResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class _$PagedMembershipPackageResponseCopyWithImpl<$Res>
    implements $PagedMembershipPackageResponseCopyWith<$Res> {
  _$PagedMembershipPackageResponseCopyWithImpl(this._self, this._then);

  final PagedMembershipPackageResponse _self;
  final $Res Function(PagedMembershipPackageResponse) _then;

/// Create a copy of PagedMembershipPackageResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MembershipPackageResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PagedMembershipPackageResponse].
extension PagedMembershipPackageResponsePatterns on PagedMembershipPackageResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PagedMembershipPackageResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PagedMembershipPackageResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PagedMembershipPackageResponse value)  $default,){
final _that = this;
switch (_that) {
case _PagedMembershipPackageResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PagedMembershipPackageResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PagedMembershipPackageResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MembershipPackageResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PagedMembershipPackageResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MembershipPackageResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)  $default,) {final _that = this;
switch (_that) {
case _PagedMembershipPackageResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MembershipPackageResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,) {final _that = this;
switch (_that) {
case _PagedMembershipPackageResponse() when $default != null:
return $default(_that.items,_that.totalCount,_that.totalPages,_that.currentPage,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PagedMembershipPackageResponse implements PagedMembershipPackageResponse {
  const _PagedMembershipPackageResponse({required final  List<MembershipPackageResponse> items, required this.totalCount, required this.totalPages, required this.currentPage, required this.pageSize}): _items = items;
  factory _PagedMembershipPackageResponse.fromJson(Map<String, dynamic> json) => _$PagedMembershipPackageResponseFromJson(json);

 final  List<MembershipPackageResponse> _items;
@override List<MembershipPackageResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int totalCount;
@override final  int totalPages;
@override final  int currentPage;
@override final  int pageSize;

/// Create a copy of PagedMembershipPackageResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagedMembershipPackageResponseCopyWith<_PagedMembershipPackageResponse> get copyWith => __$PagedMembershipPackageResponseCopyWithImpl<_PagedMembershipPackageResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PagedMembershipPackageResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagedMembershipPackageResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedMembershipPackageResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$PagedMembershipPackageResponseCopyWith<$Res> implements $PagedMembershipPackageResponseCopyWith<$Res> {
  factory _$PagedMembershipPackageResponseCopyWith(_PagedMembershipPackageResponse value, $Res Function(_PagedMembershipPackageResponse) _then) = __$PagedMembershipPackageResponseCopyWithImpl;
@override @useResult
$Res call({
 List<MembershipPackageResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class __$PagedMembershipPackageResponseCopyWithImpl<$Res>
    implements _$PagedMembershipPackageResponseCopyWith<$Res> {
  __$PagedMembershipPackageResponseCopyWithImpl(this._self, this._then);

  final _PagedMembershipPackageResponse _self;
  final $Res Function(_PagedMembershipPackageResponse) _then;

/// Create a copy of PagedMembershipPackageResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_PagedMembershipPackageResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MembershipPackageResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
