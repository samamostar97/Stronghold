// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gym_visit_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GymVisitResponse {

 int get id; int get userId; String get userFullName; String get username; DateTime get checkInAt; DateTime? get checkOutAt; int? get durationMinutes;
/// Create a copy of GymVisitResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GymVisitResponseCopyWith<GymVisitResponse> get copyWith => _$GymVisitResponseCopyWithImpl<GymVisitResponse>(this as GymVisitResponse, _$identity);

  /// Serializes this GymVisitResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GymVisitResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userFullName, userFullName) || other.userFullName == userFullName)&&(identical(other.username, username) || other.username == username)&&(identical(other.checkInAt, checkInAt) || other.checkInAt == checkInAt)&&(identical(other.checkOutAt, checkOutAt) || other.checkOutAt == checkOutAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userFullName,username,checkInAt,checkOutAt,durationMinutes);

@override
String toString() {
  return 'GymVisitResponse(id: $id, userId: $userId, userFullName: $userFullName, username: $username, checkInAt: $checkInAt, checkOutAt: $checkOutAt, durationMinutes: $durationMinutes)';
}


}

/// @nodoc
abstract mixin class $GymVisitResponseCopyWith<$Res>  {
  factory $GymVisitResponseCopyWith(GymVisitResponse value, $Res Function(GymVisitResponse) _then) = _$GymVisitResponseCopyWithImpl;
@useResult
$Res call({
 int id, int userId, String userFullName, String username, DateTime checkInAt, DateTime? checkOutAt, int? durationMinutes
});




}
/// @nodoc
class _$GymVisitResponseCopyWithImpl<$Res>
    implements $GymVisitResponseCopyWith<$Res> {
  _$GymVisitResponseCopyWithImpl(this._self, this._then);

  final GymVisitResponse _self;
  final $Res Function(GymVisitResponse) _then;

/// Create a copy of GymVisitResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? userFullName = null,Object? username = null,Object? checkInAt = null,Object? checkOutAt = freezed,Object? durationMinutes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,userFullName: null == userFullName ? _self.userFullName : userFullName // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,checkInAt: null == checkInAt ? _self.checkInAt : checkInAt // ignore: cast_nullable_to_non_nullable
as DateTime,checkOutAt: freezed == checkOutAt ? _self.checkOutAt : checkOutAt // ignore: cast_nullable_to_non_nullable
as DateTime?,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [GymVisitResponse].
extension GymVisitResponsePatterns on GymVisitResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GymVisitResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GymVisitResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GymVisitResponse value)  $default,){
final _that = this;
switch (_that) {
case _GymVisitResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GymVisitResponse value)?  $default,){
final _that = this;
switch (_that) {
case _GymVisitResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int userId,  String userFullName,  String username,  DateTime checkInAt,  DateTime? checkOutAt,  int? durationMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GymVisitResponse() when $default != null:
return $default(_that.id,_that.userId,_that.userFullName,_that.username,_that.checkInAt,_that.checkOutAt,_that.durationMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int userId,  String userFullName,  String username,  DateTime checkInAt,  DateTime? checkOutAt,  int? durationMinutes)  $default,) {final _that = this;
switch (_that) {
case _GymVisitResponse():
return $default(_that.id,_that.userId,_that.userFullName,_that.username,_that.checkInAt,_that.checkOutAt,_that.durationMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int userId,  String userFullName,  String username,  DateTime checkInAt,  DateTime? checkOutAt,  int? durationMinutes)?  $default,) {final _that = this;
switch (_that) {
case _GymVisitResponse() when $default != null:
return $default(_that.id,_that.userId,_that.userFullName,_that.username,_that.checkInAt,_that.checkOutAt,_that.durationMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GymVisitResponse implements GymVisitResponse {
  const _GymVisitResponse({required this.id, required this.userId, required this.userFullName, required this.username, required this.checkInAt, this.checkOutAt, this.durationMinutes});
  factory _GymVisitResponse.fromJson(Map<String, dynamic> json) => _$GymVisitResponseFromJson(json);

@override final  int id;
@override final  int userId;
@override final  String userFullName;
@override final  String username;
@override final  DateTime checkInAt;
@override final  DateTime? checkOutAt;
@override final  int? durationMinutes;

/// Create a copy of GymVisitResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GymVisitResponseCopyWith<_GymVisitResponse> get copyWith => __$GymVisitResponseCopyWithImpl<_GymVisitResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GymVisitResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GymVisitResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userFullName, userFullName) || other.userFullName == userFullName)&&(identical(other.username, username) || other.username == username)&&(identical(other.checkInAt, checkInAt) || other.checkInAt == checkInAt)&&(identical(other.checkOutAt, checkOutAt) || other.checkOutAt == checkOutAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userFullName,username,checkInAt,checkOutAt,durationMinutes);

@override
String toString() {
  return 'GymVisitResponse(id: $id, userId: $userId, userFullName: $userFullName, username: $username, checkInAt: $checkInAt, checkOutAt: $checkOutAt, durationMinutes: $durationMinutes)';
}


}

/// @nodoc
abstract mixin class _$GymVisitResponseCopyWith<$Res> implements $GymVisitResponseCopyWith<$Res> {
  factory _$GymVisitResponseCopyWith(_GymVisitResponse value, $Res Function(_GymVisitResponse) _then) = __$GymVisitResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, int userId, String userFullName, String username, DateTime checkInAt, DateTime? checkOutAt, int? durationMinutes
});




}
/// @nodoc
class __$GymVisitResponseCopyWithImpl<$Res>
    implements _$GymVisitResponseCopyWith<$Res> {
  __$GymVisitResponseCopyWithImpl(this._self, this._then);

  final _GymVisitResponse _self;
  final $Res Function(_GymVisitResponse) _then;

/// Create a copy of GymVisitResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? userFullName = null,Object? username = null,Object? checkInAt = null,Object? checkOutAt = freezed,Object? durationMinutes = freezed,}) {
  return _then(_GymVisitResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,userFullName: null == userFullName ? _self.userFullName : userFullName // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,checkInAt: null == checkInAt ? _self.checkInAt : checkInAt // ignore: cast_nullable_to_non_nullable
as DateTime,checkOutAt: freezed == checkOutAt ? _self.checkOutAt : checkOutAt // ignore: cast_nullable_to_non_nullable
as DateTime?,durationMinutes: freezed == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$PagedGymVisitResponse {

 List<GymVisitResponse> get items; int get totalCount; int get totalPages; int get currentPage; int get pageSize;
/// Create a copy of PagedGymVisitResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagedGymVisitResponseCopyWith<PagedGymVisitResponse> get copyWith => _$PagedGymVisitResponseCopyWithImpl<PagedGymVisitResponse>(this as PagedGymVisitResponse, _$identity);

  /// Serializes this PagedGymVisitResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagedGymVisitResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedGymVisitResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class $PagedGymVisitResponseCopyWith<$Res>  {
  factory $PagedGymVisitResponseCopyWith(PagedGymVisitResponse value, $Res Function(PagedGymVisitResponse) _then) = _$PagedGymVisitResponseCopyWithImpl;
@useResult
$Res call({
 List<GymVisitResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class _$PagedGymVisitResponseCopyWithImpl<$Res>
    implements $PagedGymVisitResponseCopyWith<$Res> {
  _$PagedGymVisitResponseCopyWithImpl(this._self, this._then);

  final PagedGymVisitResponse _self;
  final $Res Function(PagedGymVisitResponse) _then;

/// Create a copy of PagedGymVisitResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<GymVisitResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PagedGymVisitResponse].
extension PagedGymVisitResponsePatterns on PagedGymVisitResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PagedGymVisitResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PagedGymVisitResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PagedGymVisitResponse value)  $default,){
final _that = this;
switch (_that) {
case _PagedGymVisitResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PagedGymVisitResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PagedGymVisitResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GymVisitResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PagedGymVisitResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GymVisitResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)  $default,) {final _that = this;
switch (_that) {
case _PagedGymVisitResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GymVisitResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,) {final _that = this;
switch (_that) {
case _PagedGymVisitResponse() when $default != null:
return $default(_that.items,_that.totalCount,_that.totalPages,_that.currentPage,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PagedGymVisitResponse implements PagedGymVisitResponse {
  const _PagedGymVisitResponse({required final  List<GymVisitResponse> items, required this.totalCount, required this.totalPages, required this.currentPage, required this.pageSize}): _items = items;
  factory _PagedGymVisitResponse.fromJson(Map<String, dynamic> json) => _$PagedGymVisitResponseFromJson(json);

 final  List<GymVisitResponse> _items;
@override List<GymVisitResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int totalCount;
@override final  int totalPages;
@override final  int currentPage;
@override final  int pageSize;

/// Create a copy of PagedGymVisitResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagedGymVisitResponseCopyWith<_PagedGymVisitResponse> get copyWith => __$PagedGymVisitResponseCopyWithImpl<_PagedGymVisitResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PagedGymVisitResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagedGymVisitResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedGymVisitResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$PagedGymVisitResponseCopyWith<$Res> implements $PagedGymVisitResponseCopyWith<$Res> {
  factory _$PagedGymVisitResponseCopyWith(_PagedGymVisitResponse value, $Res Function(_PagedGymVisitResponse) _then) = __$PagedGymVisitResponseCopyWithImpl;
@override @useResult
$Res call({
 List<GymVisitResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class __$PagedGymVisitResponseCopyWithImpl<$Res>
    implements _$PagedGymVisitResponseCopyWith<$Res> {
  __$PagedGymVisitResponseCopyWithImpl(this._self, this._then);

  final _PagedGymVisitResponse _self;
  final $Res Function(_PagedGymVisitResponse) _then;

/// Create a copy of PagedGymVisitResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_PagedGymVisitResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<GymVisitResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
