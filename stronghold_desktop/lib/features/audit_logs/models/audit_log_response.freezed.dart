// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_log_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuditLogResponse {

 int get id; int get adminUserId; String get adminUsername; String get action; String get entityType; int get entityId; String get entitySnapshot; DateTime get createdAt; DateTime get canUndoUntil; bool get canUndo;
/// Create a copy of AuditLogResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditLogResponseCopyWith<AuditLogResponse> get copyWith => _$AuditLogResponseCopyWithImpl<AuditLogResponse>(this as AuditLogResponse, _$identity);

  /// Serializes this AuditLogResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditLogResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.adminUserId, adminUserId) || other.adminUserId == adminUserId)&&(identical(other.adminUsername, adminUsername) || other.adminUsername == adminUsername)&&(identical(other.action, action) || other.action == action)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.entitySnapshot, entitySnapshot) || other.entitySnapshot == entitySnapshot)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.canUndoUntil, canUndoUntil) || other.canUndoUntil == canUndoUntil)&&(identical(other.canUndo, canUndo) || other.canUndo == canUndo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,adminUserId,adminUsername,action,entityType,entityId,entitySnapshot,createdAt,canUndoUntil,canUndo);

@override
String toString() {
  return 'AuditLogResponse(id: $id, adminUserId: $adminUserId, adminUsername: $adminUsername, action: $action, entityType: $entityType, entityId: $entityId, entitySnapshot: $entitySnapshot, createdAt: $createdAt, canUndoUntil: $canUndoUntil, canUndo: $canUndo)';
}


}

/// @nodoc
abstract mixin class $AuditLogResponseCopyWith<$Res>  {
  factory $AuditLogResponseCopyWith(AuditLogResponse value, $Res Function(AuditLogResponse) _then) = _$AuditLogResponseCopyWithImpl;
@useResult
$Res call({
 int id, int adminUserId, String adminUsername, String action, String entityType, int entityId, String entitySnapshot, DateTime createdAt, DateTime canUndoUntil, bool canUndo
});




}
/// @nodoc
class _$AuditLogResponseCopyWithImpl<$Res>
    implements $AuditLogResponseCopyWith<$Res> {
  _$AuditLogResponseCopyWithImpl(this._self, this._then);

  final AuditLogResponse _self;
  final $Res Function(AuditLogResponse) _then;

/// Create a copy of AuditLogResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? adminUserId = null,Object? adminUsername = null,Object? action = null,Object? entityType = null,Object? entityId = null,Object? entitySnapshot = null,Object? createdAt = null,Object? canUndoUntil = null,Object? canUndo = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,adminUserId: null == adminUserId ? _self.adminUserId : adminUserId // ignore: cast_nullable_to_non_nullable
as int,adminUsername: null == adminUsername ? _self.adminUsername : adminUsername // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as int,entitySnapshot: null == entitySnapshot ? _self.entitySnapshot : entitySnapshot // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,canUndoUntil: null == canUndoUntil ? _self.canUndoUntil : canUndoUntil // ignore: cast_nullable_to_non_nullable
as DateTime,canUndo: null == canUndo ? _self.canUndo : canUndo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditLogResponse].
extension AuditLogResponsePatterns on AuditLogResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditLogResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditLogResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditLogResponse value)  $default,){
final _that = this;
switch (_that) {
case _AuditLogResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditLogResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AuditLogResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int adminUserId,  String adminUsername,  String action,  String entityType,  int entityId,  String entitySnapshot,  DateTime createdAt,  DateTime canUndoUntil,  bool canUndo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditLogResponse() when $default != null:
return $default(_that.id,_that.adminUserId,_that.adminUsername,_that.action,_that.entityType,_that.entityId,_that.entitySnapshot,_that.createdAt,_that.canUndoUntil,_that.canUndo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int adminUserId,  String adminUsername,  String action,  String entityType,  int entityId,  String entitySnapshot,  DateTime createdAt,  DateTime canUndoUntil,  bool canUndo)  $default,) {final _that = this;
switch (_that) {
case _AuditLogResponse():
return $default(_that.id,_that.adminUserId,_that.adminUsername,_that.action,_that.entityType,_that.entityId,_that.entitySnapshot,_that.createdAt,_that.canUndoUntil,_that.canUndo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int adminUserId,  String adminUsername,  String action,  String entityType,  int entityId,  String entitySnapshot,  DateTime createdAt,  DateTime canUndoUntil,  bool canUndo)?  $default,) {final _that = this;
switch (_that) {
case _AuditLogResponse() when $default != null:
return $default(_that.id,_that.adminUserId,_that.adminUsername,_that.action,_that.entityType,_that.entityId,_that.entitySnapshot,_that.createdAt,_that.canUndoUntil,_that.canUndo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditLogResponse implements AuditLogResponse {
  const _AuditLogResponse({required this.id, required this.adminUserId, required this.adminUsername, required this.action, required this.entityType, required this.entityId, required this.entitySnapshot, required this.createdAt, required this.canUndoUntil, required this.canUndo});
  factory _AuditLogResponse.fromJson(Map<String, dynamic> json) => _$AuditLogResponseFromJson(json);

@override final  int id;
@override final  int adminUserId;
@override final  String adminUsername;
@override final  String action;
@override final  String entityType;
@override final  int entityId;
@override final  String entitySnapshot;
@override final  DateTime createdAt;
@override final  DateTime canUndoUntil;
@override final  bool canUndo;

/// Create a copy of AuditLogResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditLogResponseCopyWith<_AuditLogResponse> get copyWith => __$AuditLogResponseCopyWithImpl<_AuditLogResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditLogResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditLogResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.adminUserId, adminUserId) || other.adminUserId == adminUserId)&&(identical(other.adminUsername, adminUsername) || other.adminUsername == adminUsername)&&(identical(other.action, action) || other.action == action)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.entitySnapshot, entitySnapshot) || other.entitySnapshot == entitySnapshot)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.canUndoUntil, canUndoUntil) || other.canUndoUntil == canUndoUntil)&&(identical(other.canUndo, canUndo) || other.canUndo == canUndo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,adminUserId,adminUsername,action,entityType,entityId,entitySnapshot,createdAt,canUndoUntil,canUndo);

@override
String toString() {
  return 'AuditLogResponse(id: $id, adminUserId: $adminUserId, adminUsername: $adminUsername, action: $action, entityType: $entityType, entityId: $entityId, entitySnapshot: $entitySnapshot, createdAt: $createdAt, canUndoUntil: $canUndoUntil, canUndo: $canUndo)';
}


}

/// @nodoc
abstract mixin class _$AuditLogResponseCopyWith<$Res> implements $AuditLogResponseCopyWith<$Res> {
  factory _$AuditLogResponseCopyWith(_AuditLogResponse value, $Res Function(_AuditLogResponse) _then) = __$AuditLogResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, int adminUserId, String adminUsername, String action, String entityType, int entityId, String entitySnapshot, DateTime createdAt, DateTime canUndoUntil, bool canUndo
});




}
/// @nodoc
class __$AuditLogResponseCopyWithImpl<$Res>
    implements _$AuditLogResponseCopyWith<$Res> {
  __$AuditLogResponseCopyWithImpl(this._self, this._then);

  final _AuditLogResponse _self;
  final $Res Function(_AuditLogResponse) _then;

/// Create a copy of AuditLogResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? adminUserId = null,Object? adminUsername = null,Object? action = null,Object? entityType = null,Object? entityId = null,Object? entitySnapshot = null,Object? createdAt = null,Object? canUndoUntil = null,Object? canUndo = null,}) {
  return _then(_AuditLogResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,adminUserId: null == adminUserId ? _self.adminUserId : adminUserId // ignore: cast_nullable_to_non_nullable
as int,adminUsername: null == adminUsername ? _self.adminUsername : adminUsername // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as int,entitySnapshot: null == entitySnapshot ? _self.entitySnapshot : entitySnapshot // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,canUndoUntil: null == canUndoUntil ? _self.canUndoUntil : canUndoUntil // ignore: cast_nullable_to_non_nullable
as DateTime,canUndo: null == canUndo ? _self.canUndo : canUndo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PagedAuditLogResponse {

 List<AuditLogResponse> get items; int get totalCount; int get totalPages; int get currentPage; int get pageSize;
/// Create a copy of PagedAuditLogResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagedAuditLogResponseCopyWith<PagedAuditLogResponse> get copyWith => _$PagedAuditLogResponseCopyWithImpl<PagedAuditLogResponse>(this as PagedAuditLogResponse, _$identity);

  /// Serializes this PagedAuditLogResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagedAuditLogResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedAuditLogResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class $PagedAuditLogResponseCopyWith<$Res>  {
  factory $PagedAuditLogResponseCopyWith(PagedAuditLogResponse value, $Res Function(PagedAuditLogResponse) _then) = _$PagedAuditLogResponseCopyWithImpl;
@useResult
$Res call({
 List<AuditLogResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class _$PagedAuditLogResponseCopyWithImpl<$Res>
    implements $PagedAuditLogResponseCopyWith<$Res> {
  _$PagedAuditLogResponseCopyWithImpl(this._self, this._then);

  final PagedAuditLogResponse _self;
  final $Res Function(PagedAuditLogResponse) _then;

/// Create a copy of PagedAuditLogResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AuditLogResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PagedAuditLogResponse].
extension PagedAuditLogResponsePatterns on PagedAuditLogResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PagedAuditLogResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PagedAuditLogResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PagedAuditLogResponse value)  $default,){
final _that = this;
switch (_that) {
case _PagedAuditLogResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PagedAuditLogResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PagedAuditLogResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AuditLogResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PagedAuditLogResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AuditLogResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)  $default,) {final _that = this;
switch (_that) {
case _PagedAuditLogResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AuditLogResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,) {final _that = this;
switch (_that) {
case _PagedAuditLogResponse() when $default != null:
return $default(_that.items,_that.totalCount,_that.totalPages,_that.currentPage,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PagedAuditLogResponse implements PagedAuditLogResponse {
  const _PagedAuditLogResponse({required final  List<AuditLogResponse> items, required this.totalCount, required this.totalPages, required this.currentPage, required this.pageSize}): _items = items;
  factory _PagedAuditLogResponse.fromJson(Map<String, dynamic> json) => _$PagedAuditLogResponseFromJson(json);

 final  List<AuditLogResponse> _items;
@override List<AuditLogResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int totalCount;
@override final  int totalPages;
@override final  int currentPage;
@override final  int pageSize;

/// Create a copy of PagedAuditLogResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagedAuditLogResponseCopyWith<_PagedAuditLogResponse> get copyWith => __$PagedAuditLogResponseCopyWithImpl<_PagedAuditLogResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PagedAuditLogResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagedAuditLogResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedAuditLogResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$PagedAuditLogResponseCopyWith<$Res> implements $PagedAuditLogResponseCopyWith<$Res> {
  factory _$PagedAuditLogResponseCopyWith(_PagedAuditLogResponse value, $Res Function(_PagedAuditLogResponse) _then) = __$PagedAuditLogResponseCopyWithImpl;
@override @useResult
$Res call({
 List<AuditLogResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class __$PagedAuditLogResponseCopyWithImpl<$Res>
    implements _$PagedAuditLogResponseCopyWith<$Res> {
  __$PagedAuditLogResponseCopyWithImpl(this._self, this._then);

  final _PagedAuditLogResponse _self;
  final $Res Function(_PagedAuditLogResponse) _then;

/// Create a copy of PagedAuditLogResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_PagedAuditLogResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AuditLogResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
