// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppointmentResponse {

 int get id; int get userId; String get userName; int get staffId; String get staffName; String get staffType; DateTime get scheduledAt; int get durationMinutes; String get status; String? get notes; DateTime get createdAt;
/// Create a copy of AppointmentResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppointmentResponseCopyWith<AppointmentResponse> get copyWith => _$AppointmentResponseCopyWithImpl<AppointmentResponse>(this as AppointmentResponse, _$identity);

  /// Serializes this AppointmentResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppointmentResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.staffName, staffName) || other.staffName == staffName)&&(identical(other.staffType, staffType) || other.staffType == staffType)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,staffId,staffName,staffType,scheduledAt,durationMinutes,status,notes,createdAt);

@override
String toString() {
  return 'AppointmentResponse(id: $id, userId: $userId, userName: $userName, staffId: $staffId, staffName: $staffName, staffType: $staffType, scheduledAt: $scheduledAt, durationMinutes: $durationMinutes, status: $status, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AppointmentResponseCopyWith<$Res>  {
  factory $AppointmentResponseCopyWith(AppointmentResponse value, $Res Function(AppointmentResponse) _then) = _$AppointmentResponseCopyWithImpl;
@useResult
$Res call({
 int id, int userId, String userName, int staffId, String staffName, String staffType, DateTime scheduledAt, int durationMinutes, String status, String? notes, DateTime createdAt
});




}
/// @nodoc
class _$AppointmentResponseCopyWithImpl<$Res>
    implements $AppointmentResponseCopyWith<$Res> {
  _$AppointmentResponseCopyWithImpl(this._self, this._then);

  final AppointmentResponse _self;
  final $Res Function(AppointmentResponse) _then;

/// Create a copy of AppointmentResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? userName = null,Object? staffId = null,Object? staffName = null,Object? staffType = null,Object? scheduledAt = null,Object? durationMinutes = null,Object? status = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,staffId: null == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as int,staffName: null == staffName ? _self.staffName : staffName // ignore: cast_nullable_to_non_nullable
as String,staffType: null == staffType ? _self.staffType : staffType // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AppointmentResponse].
extension AppointmentResponsePatterns on AppointmentResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppointmentResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppointmentResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppointmentResponse value)  $default,){
final _that = this;
switch (_that) {
case _AppointmentResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppointmentResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AppointmentResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int userId,  String userName,  int staffId,  String staffName,  String staffType,  DateTime scheduledAt,  int durationMinutes,  String status,  String? notes,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppointmentResponse() when $default != null:
return $default(_that.id,_that.userId,_that.userName,_that.staffId,_that.staffName,_that.staffType,_that.scheduledAt,_that.durationMinutes,_that.status,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int userId,  String userName,  int staffId,  String staffName,  String staffType,  DateTime scheduledAt,  int durationMinutes,  String status,  String? notes,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AppointmentResponse():
return $default(_that.id,_that.userId,_that.userName,_that.staffId,_that.staffName,_that.staffType,_that.scheduledAt,_that.durationMinutes,_that.status,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int userId,  String userName,  int staffId,  String staffName,  String staffType,  DateTime scheduledAt,  int durationMinutes,  String status,  String? notes,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AppointmentResponse() when $default != null:
return $default(_that.id,_that.userId,_that.userName,_that.staffId,_that.staffName,_that.staffType,_that.scheduledAt,_that.durationMinutes,_that.status,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppointmentResponse implements AppointmentResponse {
  const _AppointmentResponse({required this.id, required this.userId, required this.userName, required this.staffId, required this.staffName, required this.staffType, required this.scheduledAt, required this.durationMinutes, required this.status, this.notes, required this.createdAt});
  factory _AppointmentResponse.fromJson(Map<String, dynamic> json) => _$AppointmentResponseFromJson(json);

@override final  int id;
@override final  int userId;
@override final  String userName;
@override final  int staffId;
@override final  String staffName;
@override final  String staffType;
@override final  DateTime scheduledAt;
@override final  int durationMinutes;
@override final  String status;
@override final  String? notes;
@override final  DateTime createdAt;

/// Create a copy of AppointmentResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppointmentResponseCopyWith<_AppointmentResponse> get copyWith => __$AppointmentResponseCopyWithImpl<_AppointmentResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppointmentResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppointmentResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.staffId, staffId) || other.staffId == staffId)&&(identical(other.staffName, staffName) || other.staffName == staffName)&&(identical(other.staffType, staffType) || other.staffType == staffType)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userName,staffId,staffName,staffType,scheduledAt,durationMinutes,status,notes,createdAt);

@override
String toString() {
  return 'AppointmentResponse(id: $id, userId: $userId, userName: $userName, staffId: $staffId, staffName: $staffName, staffType: $staffType, scheduledAt: $scheduledAt, durationMinutes: $durationMinutes, status: $status, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AppointmentResponseCopyWith<$Res> implements $AppointmentResponseCopyWith<$Res> {
  factory _$AppointmentResponseCopyWith(_AppointmentResponse value, $Res Function(_AppointmentResponse) _then) = __$AppointmentResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, int userId, String userName, int staffId, String staffName, String staffType, DateTime scheduledAt, int durationMinutes, String status, String? notes, DateTime createdAt
});




}
/// @nodoc
class __$AppointmentResponseCopyWithImpl<$Res>
    implements _$AppointmentResponseCopyWith<$Res> {
  __$AppointmentResponseCopyWithImpl(this._self, this._then);

  final _AppointmentResponse _self;
  final $Res Function(_AppointmentResponse) _then;

/// Create a copy of AppointmentResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? userName = null,Object? staffId = null,Object? staffName = null,Object? staffType = null,Object? scheduledAt = null,Object? durationMinutes = null,Object? status = null,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_AppointmentResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,staffId: null == staffId ? _self.staffId : staffId // ignore: cast_nullable_to_non_nullable
as int,staffName: null == staffName ? _self.staffName : staffName // ignore: cast_nullable_to_non_nullable
as String,staffType: null == staffType ? _self.staffType : staffType // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$PagedAppointmentResponse {

 List<AppointmentResponse> get items; int get totalCount; int get totalPages; int get currentPage; int get pageSize;
/// Create a copy of PagedAppointmentResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagedAppointmentResponseCopyWith<PagedAppointmentResponse> get copyWith => _$PagedAppointmentResponseCopyWithImpl<PagedAppointmentResponse>(this as PagedAppointmentResponse, _$identity);

  /// Serializes this PagedAppointmentResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagedAppointmentResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedAppointmentResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class $PagedAppointmentResponseCopyWith<$Res>  {
  factory $PagedAppointmentResponseCopyWith(PagedAppointmentResponse value, $Res Function(PagedAppointmentResponse) _then) = _$PagedAppointmentResponseCopyWithImpl;
@useResult
$Res call({
 List<AppointmentResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class _$PagedAppointmentResponseCopyWithImpl<$Res>
    implements $PagedAppointmentResponseCopyWith<$Res> {
  _$PagedAppointmentResponseCopyWithImpl(this._self, this._then);

  final PagedAppointmentResponse _self;
  final $Res Function(PagedAppointmentResponse) _then;

/// Create a copy of PagedAppointmentResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AppointmentResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PagedAppointmentResponse].
extension PagedAppointmentResponsePatterns on PagedAppointmentResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PagedAppointmentResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PagedAppointmentResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PagedAppointmentResponse value)  $default,){
final _that = this;
switch (_that) {
case _PagedAppointmentResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PagedAppointmentResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PagedAppointmentResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AppointmentResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PagedAppointmentResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AppointmentResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)  $default,) {final _that = this;
switch (_that) {
case _PagedAppointmentResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AppointmentResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,) {final _that = this;
switch (_that) {
case _PagedAppointmentResponse() when $default != null:
return $default(_that.items,_that.totalCount,_that.totalPages,_that.currentPage,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PagedAppointmentResponse implements PagedAppointmentResponse {
  const _PagedAppointmentResponse({required final  List<AppointmentResponse> items, required this.totalCount, required this.totalPages, required this.currentPage, required this.pageSize}): _items = items;
  factory _PagedAppointmentResponse.fromJson(Map<String, dynamic> json) => _$PagedAppointmentResponseFromJson(json);

 final  List<AppointmentResponse> _items;
@override List<AppointmentResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int totalCount;
@override final  int totalPages;
@override final  int currentPage;
@override final  int pageSize;

/// Create a copy of PagedAppointmentResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagedAppointmentResponseCopyWith<_PagedAppointmentResponse> get copyWith => __$PagedAppointmentResponseCopyWithImpl<_PagedAppointmentResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PagedAppointmentResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagedAppointmentResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedAppointmentResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$PagedAppointmentResponseCopyWith<$Res> implements $PagedAppointmentResponseCopyWith<$Res> {
  factory _$PagedAppointmentResponseCopyWith(_PagedAppointmentResponse value, $Res Function(_PagedAppointmentResponse) _then) = __$PagedAppointmentResponseCopyWithImpl;
@override @useResult
$Res call({
 List<AppointmentResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class __$PagedAppointmentResponseCopyWithImpl<$Res>
    implements _$PagedAppointmentResponseCopyWith<$Res> {
  __$PagedAppointmentResponseCopyWithImpl(this._self, this._then);

  final _PagedAppointmentResponse _self;
  final $Res Function(_PagedAppointmentResponse) _then;

/// Create a copy of PagedAppointmentResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_PagedAppointmentResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AppointmentResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
