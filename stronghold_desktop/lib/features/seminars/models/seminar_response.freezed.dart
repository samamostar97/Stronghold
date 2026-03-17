// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seminar_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SeminarResponse {

 int get id; String get name; String get description; String get lecturer; DateTime get startDate; int get durationMinutes; int get maxCapacity; int get registeredCount; DateTime get createdAt;
/// Create a copy of SeminarResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeminarResponseCopyWith<SeminarResponse> get copyWith => _$SeminarResponseCopyWithImpl<SeminarResponse>(this as SeminarResponse, _$identity);

  /// Serializes this SeminarResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeminarResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.lecturer, lecturer) || other.lecturer == lecturer)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity)&&(identical(other.registeredCount, registeredCount) || other.registeredCount == registeredCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,lecturer,startDate,durationMinutes,maxCapacity,registeredCount,createdAt);

@override
String toString() {
  return 'SeminarResponse(id: $id, name: $name, description: $description, lecturer: $lecturer, startDate: $startDate, durationMinutes: $durationMinutes, maxCapacity: $maxCapacity, registeredCount: $registeredCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SeminarResponseCopyWith<$Res>  {
  factory $SeminarResponseCopyWith(SeminarResponse value, $Res Function(SeminarResponse) _then) = _$SeminarResponseCopyWithImpl;
@useResult
$Res call({
 int id, String name, String description, String lecturer, DateTime startDate, int durationMinutes, int maxCapacity, int registeredCount, DateTime createdAt
});




}
/// @nodoc
class _$SeminarResponseCopyWithImpl<$Res>
    implements $SeminarResponseCopyWith<$Res> {
  _$SeminarResponseCopyWithImpl(this._self, this._then);

  final SeminarResponse _self;
  final $Res Function(SeminarResponse) _then;

/// Create a copy of SeminarResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? lecturer = null,Object? startDate = null,Object? durationMinutes = null,Object? maxCapacity = null,Object? registeredCount = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,lecturer: null == lecturer ? _self.lecturer : lecturer // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,maxCapacity: null == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int,registeredCount: null == registeredCount ? _self.registeredCount : registeredCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SeminarResponse].
extension SeminarResponsePatterns on SeminarResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeminarResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeminarResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeminarResponse value)  $default,){
final _that = this;
switch (_that) {
case _SeminarResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeminarResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SeminarResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String description,  String lecturer,  DateTime startDate,  int durationMinutes,  int maxCapacity,  int registeredCount,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeminarResponse() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.lecturer,_that.startDate,_that.durationMinutes,_that.maxCapacity,_that.registeredCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String description,  String lecturer,  DateTime startDate,  int durationMinutes,  int maxCapacity,  int registeredCount,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _SeminarResponse():
return $default(_that.id,_that.name,_that.description,_that.lecturer,_that.startDate,_that.durationMinutes,_that.maxCapacity,_that.registeredCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String description,  String lecturer,  DateTime startDate,  int durationMinutes,  int maxCapacity,  int registeredCount,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SeminarResponse() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.lecturer,_that.startDate,_that.durationMinutes,_that.maxCapacity,_that.registeredCount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeminarResponse implements SeminarResponse {
  const _SeminarResponse({required this.id, required this.name, required this.description, required this.lecturer, required this.startDate, required this.durationMinutes, required this.maxCapacity, required this.registeredCount, required this.createdAt});
  factory _SeminarResponse.fromJson(Map<String, dynamic> json) => _$SeminarResponseFromJson(json);

@override final  int id;
@override final  String name;
@override final  String description;
@override final  String lecturer;
@override final  DateTime startDate;
@override final  int durationMinutes;
@override final  int maxCapacity;
@override final  int registeredCount;
@override final  DateTime createdAt;

/// Create a copy of SeminarResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeminarResponseCopyWith<_SeminarResponse> get copyWith => __$SeminarResponseCopyWithImpl<_SeminarResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeminarResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeminarResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.lecturer, lecturer) || other.lecturer == lecturer)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity)&&(identical(other.registeredCount, registeredCount) || other.registeredCount == registeredCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,lecturer,startDate,durationMinutes,maxCapacity,registeredCount,createdAt);

@override
String toString() {
  return 'SeminarResponse(id: $id, name: $name, description: $description, lecturer: $lecturer, startDate: $startDate, durationMinutes: $durationMinutes, maxCapacity: $maxCapacity, registeredCount: $registeredCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SeminarResponseCopyWith<$Res> implements $SeminarResponseCopyWith<$Res> {
  factory _$SeminarResponseCopyWith(_SeminarResponse value, $Res Function(_SeminarResponse) _then) = __$SeminarResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String description, String lecturer, DateTime startDate, int durationMinutes, int maxCapacity, int registeredCount, DateTime createdAt
});




}
/// @nodoc
class __$SeminarResponseCopyWithImpl<$Res>
    implements _$SeminarResponseCopyWith<$Res> {
  __$SeminarResponseCopyWithImpl(this._self, this._then);

  final _SeminarResponse _self;
  final $Res Function(_SeminarResponse) _then;

/// Create a copy of SeminarResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? lecturer = null,Object? startDate = null,Object? durationMinutes = null,Object? maxCapacity = null,Object? registeredCount = null,Object? createdAt = null,}) {
  return _then(_SeminarResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,lecturer: null == lecturer ? _self.lecturer : lecturer // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,maxCapacity: null == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int,registeredCount: null == registeredCount ? _self.registeredCount : registeredCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$PagedSeminarResponse {

 List<SeminarResponse> get items; int get totalCount; int get totalPages; int get currentPage; int get pageSize;
/// Create a copy of PagedSeminarResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagedSeminarResponseCopyWith<PagedSeminarResponse> get copyWith => _$PagedSeminarResponseCopyWithImpl<PagedSeminarResponse>(this as PagedSeminarResponse, _$identity);

  /// Serializes this PagedSeminarResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagedSeminarResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedSeminarResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class $PagedSeminarResponseCopyWith<$Res>  {
  factory $PagedSeminarResponseCopyWith(PagedSeminarResponse value, $Res Function(PagedSeminarResponse) _then) = _$PagedSeminarResponseCopyWithImpl;
@useResult
$Res call({
 List<SeminarResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class _$PagedSeminarResponseCopyWithImpl<$Res>
    implements $PagedSeminarResponseCopyWith<$Res> {
  _$PagedSeminarResponseCopyWithImpl(this._self, this._then);

  final PagedSeminarResponse _self;
  final $Res Function(PagedSeminarResponse) _then;

/// Create a copy of PagedSeminarResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SeminarResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PagedSeminarResponse].
extension PagedSeminarResponsePatterns on PagedSeminarResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PagedSeminarResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PagedSeminarResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PagedSeminarResponse value)  $default,){
final _that = this;
switch (_that) {
case _PagedSeminarResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PagedSeminarResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PagedSeminarResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SeminarResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PagedSeminarResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SeminarResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)  $default,) {final _that = this;
switch (_that) {
case _PagedSeminarResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SeminarResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,) {final _that = this;
switch (_that) {
case _PagedSeminarResponse() when $default != null:
return $default(_that.items,_that.totalCount,_that.totalPages,_that.currentPage,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PagedSeminarResponse implements PagedSeminarResponse {
  const _PagedSeminarResponse({required final  List<SeminarResponse> items, required this.totalCount, required this.totalPages, required this.currentPage, required this.pageSize}): _items = items;
  factory _PagedSeminarResponse.fromJson(Map<String, dynamic> json) => _$PagedSeminarResponseFromJson(json);

 final  List<SeminarResponse> _items;
@override List<SeminarResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int totalCount;
@override final  int totalPages;
@override final  int currentPage;
@override final  int pageSize;

/// Create a copy of PagedSeminarResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagedSeminarResponseCopyWith<_PagedSeminarResponse> get copyWith => __$PagedSeminarResponseCopyWithImpl<_PagedSeminarResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PagedSeminarResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagedSeminarResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedSeminarResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$PagedSeminarResponseCopyWith<$Res> implements $PagedSeminarResponseCopyWith<$Res> {
  factory _$PagedSeminarResponseCopyWith(_PagedSeminarResponse value, $Res Function(_PagedSeminarResponse) _then) = __$PagedSeminarResponseCopyWithImpl;
@override @useResult
$Res call({
 List<SeminarResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class __$PagedSeminarResponseCopyWithImpl<$Res>
    implements _$PagedSeminarResponseCopyWith<$Res> {
  __$PagedSeminarResponseCopyWithImpl(this._self, this._then);

  final _PagedSeminarResponse _self;
  final $Res Function(_PagedSeminarResponse) _then;

/// Create a copy of PagedSeminarResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_PagedSeminarResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SeminarResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SeminarRegistrationResponse {

 int get id; int get userId; String get userFullName; String get userEmail; DateTime get createdAt;
/// Create a copy of SeminarRegistrationResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeminarRegistrationResponseCopyWith<SeminarRegistrationResponse> get copyWith => _$SeminarRegistrationResponseCopyWithImpl<SeminarRegistrationResponse>(this as SeminarRegistrationResponse, _$identity);

  /// Serializes this SeminarRegistrationResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeminarRegistrationResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userFullName, userFullName) || other.userFullName == userFullName)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userFullName,userEmail,createdAt);

@override
String toString() {
  return 'SeminarRegistrationResponse(id: $id, userId: $userId, userFullName: $userFullName, userEmail: $userEmail, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SeminarRegistrationResponseCopyWith<$Res>  {
  factory $SeminarRegistrationResponseCopyWith(SeminarRegistrationResponse value, $Res Function(SeminarRegistrationResponse) _then) = _$SeminarRegistrationResponseCopyWithImpl;
@useResult
$Res call({
 int id, int userId, String userFullName, String userEmail, DateTime createdAt
});




}
/// @nodoc
class _$SeminarRegistrationResponseCopyWithImpl<$Res>
    implements $SeminarRegistrationResponseCopyWith<$Res> {
  _$SeminarRegistrationResponseCopyWithImpl(this._self, this._then);

  final SeminarRegistrationResponse _self;
  final $Res Function(SeminarRegistrationResponse) _then;

/// Create a copy of SeminarRegistrationResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? userFullName = null,Object? userEmail = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,userFullName: null == userFullName ? _self.userFullName : userFullName // ignore: cast_nullable_to_non_nullable
as String,userEmail: null == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SeminarRegistrationResponse].
extension SeminarRegistrationResponsePatterns on SeminarRegistrationResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeminarRegistrationResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeminarRegistrationResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeminarRegistrationResponse value)  $default,){
final _that = this;
switch (_that) {
case _SeminarRegistrationResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeminarRegistrationResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SeminarRegistrationResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int userId,  String userFullName,  String userEmail,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeminarRegistrationResponse() when $default != null:
return $default(_that.id,_that.userId,_that.userFullName,_that.userEmail,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int userId,  String userFullName,  String userEmail,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _SeminarRegistrationResponse():
return $default(_that.id,_that.userId,_that.userFullName,_that.userEmail,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int userId,  String userFullName,  String userEmail,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SeminarRegistrationResponse() when $default != null:
return $default(_that.id,_that.userId,_that.userFullName,_that.userEmail,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeminarRegistrationResponse implements SeminarRegistrationResponse {
  const _SeminarRegistrationResponse({required this.id, required this.userId, required this.userFullName, required this.userEmail, required this.createdAt});
  factory _SeminarRegistrationResponse.fromJson(Map<String, dynamic> json) => _$SeminarRegistrationResponseFromJson(json);

@override final  int id;
@override final  int userId;
@override final  String userFullName;
@override final  String userEmail;
@override final  DateTime createdAt;

/// Create a copy of SeminarRegistrationResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeminarRegistrationResponseCopyWith<_SeminarRegistrationResponse> get copyWith => __$SeminarRegistrationResponseCopyWithImpl<_SeminarRegistrationResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeminarRegistrationResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeminarRegistrationResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userFullName, userFullName) || other.userFullName == userFullName)&&(identical(other.userEmail, userEmail) || other.userEmail == userEmail)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userFullName,userEmail,createdAt);

@override
String toString() {
  return 'SeminarRegistrationResponse(id: $id, userId: $userId, userFullName: $userFullName, userEmail: $userEmail, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SeminarRegistrationResponseCopyWith<$Res> implements $SeminarRegistrationResponseCopyWith<$Res> {
  factory _$SeminarRegistrationResponseCopyWith(_SeminarRegistrationResponse value, $Res Function(_SeminarRegistrationResponse) _then) = __$SeminarRegistrationResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, int userId, String userFullName, String userEmail, DateTime createdAt
});




}
/// @nodoc
class __$SeminarRegistrationResponseCopyWithImpl<$Res>
    implements _$SeminarRegistrationResponseCopyWith<$Res> {
  __$SeminarRegistrationResponseCopyWithImpl(this._self, this._then);

  final _SeminarRegistrationResponse _self;
  final $Res Function(_SeminarRegistrationResponse) _then;

/// Create a copy of SeminarRegistrationResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? userFullName = null,Object? userEmail = null,Object? createdAt = null,}) {
  return _then(_SeminarRegistrationResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,userFullName: null == userFullName ? _self.userFullName : userFullName // ignore: cast_nullable_to_non_nullable
as String,userEmail: null == userEmail ? _self.userEmail : userEmail // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
