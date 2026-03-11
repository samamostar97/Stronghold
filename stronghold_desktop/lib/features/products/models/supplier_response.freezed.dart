// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'supplier_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SupplierResponse {

 int get id; String get name; String? get email; String? get phone; String? get website; DateTime get createdAt;
/// Create a copy of SupplierResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupplierResponseCopyWith<SupplierResponse> get copyWith => _$SupplierResponseCopyWithImpl<SupplierResponse>(this as SupplierResponse, _$identity);

  /// Serializes this SupplierResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupplierResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.website, website) || other.website == website)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,phone,website,createdAt);

@override
String toString() {
  return 'SupplierResponse(id: $id, name: $name, email: $email, phone: $phone, website: $website, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SupplierResponseCopyWith<$Res>  {
  factory $SupplierResponseCopyWith(SupplierResponse value, $Res Function(SupplierResponse) _then) = _$SupplierResponseCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? email, String? phone, String? website, DateTime createdAt
});




}
/// @nodoc
class _$SupplierResponseCopyWithImpl<$Res>
    implements $SupplierResponseCopyWith<$Res> {
  _$SupplierResponseCopyWithImpl(this._self, this._then);

  final SupplierResponse _self;
  final $Res Function(SupplierResponse) _then;

/// Create a copy of SupplierResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? website = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SupplierResponse].
extension SupplierResponsePatterns on SupplierResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupplierResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupplierResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupplierResponse value)  $default,){
final _that = this;
switch (_that) {
case _SupplierResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupplierResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SupplierResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? email,  String? phone,  String? website,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupplierResponse() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.website,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? email,  String? phone,  String? website,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _SupplierResponse():
return $default(_that.id,_that.name,_that.email,_that.phone,_that.website,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? email,  String? phone,  String? website,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SupplierResponse() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.website,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SupplierResponse implements SupplierResponse {
  const _SupplierResponse({required this.id, required this.name, this.email, this.phone, this.website, required this.createdAt});
  factory _SupplierResponse.fromJson(Map<String, dynamic> json) => _$SupplierResponseFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? email;
@override final  String? phone;
@override final  String? website;
@override final  DateTime createdAt;

/// Create a copy of SupplierResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupplierResponseCopyWith<_SupplierResponse> get copyWith => __$SupplierResponseCopyWithImpl<_SupplierResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SupplierResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupplierResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.website, website) || other.website == website)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,phone,website,createdAt);

@override
String toString() {
  return 'SupplierResponse(id: $id, name: $name, email: $email, phone: $phone, website: $website, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SupplierResponseCopyWith<$Res> implements $SupplierResponseCopyWith<$Res> {
  factory _$SupplierResponseCopyWith(_SupplierResponse value, $Res Function(_SupplierResponse) _then) = __$SupplierResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? email, String? phone, String? website, DateTime createdAt
});




}
/// @nodoc
class __$SupplierResponseCopyWithImpl<$Res>
    implements _$SupplierResponseCopyWith<$Res> {
  __$SupplierResponseCopyWithImpl(this._self, this._then);

  final _SupplierResponse _self;
  final $Res Function(_SupplierResponse) _then;

/// Create a copy of SupplierResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? website = freezed,Object? createdAt = null,}) {
  return _then(_SupplierResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$PagedSupplierResponse {

 List<SupplierResponse> get items; int get totalCount; int get totalPages; int get currentPage; int get pageSize;
/// Create a copy of PagedSupplierResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagedSupplierResponseCopyWith<PagedSupplierResponse> get copyWith => _$PagedSupplierResponseCopyWithImpl<PagedSupplierResponse>(this as PagedSupplierResponse, _$identity);

  /// Serializes this PagedSupplierResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagedSupplierResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedSupplierResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class $PagedSupplierResponseCopyWith<$Res>  {
  factory $PagedSupplierResponseCopyWith(PagedSupplierResponse value, $Res Function(PagedSupplierResponse) _then) = _$PagedSupplierResponseCopyWithImpl;
@useResult
$Res call({
 List<SupplierResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class _$PagedSupplierResponseCopyWithImpl<$Res>
    implements $PagedSupplierResponseCopyWith<$Res> {
  _$PagedSupplierResponseCopyWithImpl(this._self, this._then);

  final PagedSupplierResponse _self;
  final $Res Function(PagedSupplierResponse) _then;

/// Create a copy of PagedSupplierResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SupplierResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PagedSupplierResponse].
extension PagedSupplierResponsePatterns on PagedSupplierResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PagedSupplierResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PagedSupplierResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PagedSupplierResponse value)  $default,){
final _that = this;
switch (_that) {
case _PagedSupplierResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PagedSupplierResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PagedSupplierResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SupplierResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PagedSupplierResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SupplierResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)  $default,) {final _that = this;
switch (_that) {
case _PagedSupplierResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SupplierResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,) {final _that = this;
switch (_that) {
case _PagedSupplierResponse() when $default != null:
return $default(_that.items,_that.totalCount,_that.totalPages,_that.currentPage,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PagedSupplierResponse implements PagedSupplierResponse {
  const _PagedSupplierResponse({required final  List<SupplierResponse> items, required this.totalCount, required this.totalPages, required this.currentPage, required this.pageSize}): _items = items;
  factory _PagedSupplierResponse.fromJson(Map<String, dynamic> json) => _$PagedSupplierResponseFromJson(json);

 final  List<SupplierResponse> _items;
@override List<SupplierResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int totalCount;
@override final  int totalPages;
@override final  int currentPage;
@override final  int pageSize;

/// Create a copy of PagedSupplierResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagedSupplierResponseCopyWith<_PagedSupplierResponse> get copyWith => __$PagedSupplierResponseCopyWithImpl<_PagedSupplierResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PagedSupplierResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagedSupplierResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedSupplierResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$PagedSupplierResponseCopyWith<$Res> implements $PagedSupplierResponseCopyWith<$Res> {
  factory _$PagedSupplierResponseCopyWith(_PagedSupplierResponse value, $Res Function(_PagedSupplierResponse) _then) = __$PagedSupplierResponseCopyWithImpl;
@override @useResult
$Res call({
 List<SupplierResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class __$PagedSupplierResponseCopyWithImpl<$Res>
    implements _$PagedSupplierResponseCopyWith<$Res> {
  __$PagedSupplierResponseCopyWithImpl(this._self, this._then);

  final _PagedSupplierResponse _self;
  final $Res Function(_PagedSupplierResponse) _then;

/// Create a copy of PagedSupplierResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_PagedSupplierResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SupplierResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
