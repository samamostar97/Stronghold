// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_membership_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserMembershipResponse {

 int get id; int get userId; String get userFullName; int get membershipPackageId; String get membershipPackageName; double get membershipPackagePrice; DateTime get startDate; DateTime get endDate; bool get isActive; DateTime get createdAt;
/// Create a copy of UserMembershipResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserMembershipResponseCopyWith<UserMembershipResponse> get copyWith => _$UserMembershipResponseCopyWithImpl<UserMembershipResponse>(this as UserMembershipResponse, _$identity);

  /// Serializes this UserMembershipResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserMembershipResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userFullName, userFullName) || other.userFullName == userFullName)&&(identical(other.membershipPackageId, membershipPackageId) || other.membershipPackageId == membershipPackageId)&&(identical(other.membershipPackageName, membershipPackageName) || other.membershipPackageName == membershipPackageName)&&(identical(other.membershipPackagePrice, membershipPackagePrice) || other.membershipPackagePrice == membershipPackagePrice)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userFullName,membershipPackageId,membershipPackageName,membershipPackagePrice,startDate,endDate,isActive,createdAt);

@override
String toString() {
  return 'UserMembershipResponse(id: $id, userId: $userId, userFullName: $userFullName, membershipPackageId: $membershipPackageId, membershipPackageName: $membershipPackageName, membershipPackagePrice: $membershipPackagePrice, startDate: $startDate, endDate: $endDate, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $UserMembershipResponseCopyWith<$Res>  {
  factory $UserMembershipResponseCopyWith(UserMembershipResponse value, $Res Function(UserMembershipResponse) _then) = _$UserMembershipResponseCopyWithImpl;
@useResult
$Res call({
 int id, int userId, String userFullName, int membershipPackageId, String membershipPackageName, double membershipPackagePrice, DateTime startDate, DateTime endDate, bool isActive, DateTime createdAt
});




}
/// @nodoc
class _$UserMembershipResponseCopyWithImpl<$Res>
    implements $UserMembershipResponseCopyWith<$Res> {
  _$UserMembershipResponseCopyWithImpl(this._self, this._then);

  final UserMembershipResponse _self;
  final $Res Function(UserMembershipResponse) _then;

/// Create a copy of UserMembershipResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? userFullName = null,Object? membershipPackageId = null,Object? membershipPackageName = null,Object? membershipPackagePrice = null,Object? startDate = null,Object? endDate = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,userFullName: null == userFullName ? _self.userFullName : userFullName // ignore: cast_nullable_to_non_nullable
as String,membershipPackageId: null == membershipPackageId ? _self.membershipPackageId : membershipPackageId // ignore: cast_nullable_to_non_nullable
as int,membershipPackageName: null == membershipPackageName ? _self.membershipPackageName : membershipPackageName // ignore: cast_nullable_to_non_nullable
as String,membershipPackagePrice: null == membershipPackagePrice ? _self.membershipPackagePrice : membershipPackagePrice // ignore: cast_nullable_to_non_nullable
as double,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UserMembershipResponse].
extension UserMembershipResponsePatterns on UserMembershipResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserMembershipResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserMembershipResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserMembershipResponse value)  $default,){
final _that = this;
switch (_that) {
case _UserMembershipResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserMembershipResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UserMembershipResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int userId,  String userFullName,  int membershipPackageId,  String membershipPackageName,  double membershipPackagePrice,  DateTime startDate,  DateTime endDate,  bool isActive,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserMembershipResponse() when $default != null:
return $default(_that.id,_that.userId,_that.userFullName,_that.membershipPackageId,_that.membershipPackageName,_that.membershipPackagePrice,_that.startDate,_that.endDate,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int userId,  String userFullName,  int membershipPackageId,  String membershipPackageName,  double membershipPackagePrice,  DateTime startDate,  DateTime endDate,  bool isActive,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _UserMembershipResponse():
return $default(_that.id,_that.userId,_that.userFullName,_that.membershipPackageId,_that.membershipPackageName,_that.membershipPackagePrice,_that.startDate,_that.endDate,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int userId,  String userFullName,  int membershipPackageId,  String membershipPackageName,  double membershipPackagePrice,  DateTime startDate,  DateTime endDate,  bool isActive,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _UserMembershipResponse() when $default != null:
return $default(_that.id,_that.userId,_that.userFullName,_that.membershipPackageId,_that.membershipPackageName,_that.membershipPackagePrice,_that.startDate,_that.endDate,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserMembershipResponse implements UserMembershipResponse {
  const _UserMembershipResponse({required this.id, required this.userId, required this.userFullName, required this.membershipPackageId, required this.membershipPackageName, required this.membershipPackagePrice, required this.startDate, required this.endDate, required this.isActive, required this.createdAt});
  factory _UserMembershipResponse.fromJson(Map<String, dynamic> json) => _$UserMembershipResponseFromJson(json);

@override final  int id;
@override final  int userId;
@override final  String userFullName;
@override final  int membershipPackageId;
@override final  String membershipPackageName;
@override final  double membershipPackagePrice;
@override final  DateTime startDate;
@override final  DateTime endDate;
@override final  bool isActive;
@override final  DateTime createdAt;

/// Create a copy of UserMembershipResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserMembershipResponseCopyWith<_UserMembershipResponse> get copyWith => __$UserMembershipResponseCopyWithImpl<_UserMembershipResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserMembershipResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserMembershipResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userFullName, userFullName) || other.userFullName == userFullName)&&(identical(other.membershipPackageId, membershipPackageId) || other.membershipPackageId == membershipPackageId)&&(identical(other.membershipPackageName, membershipPackageName) || other.membershipPackageName == membershipPackageName)&&(identical(other.membershipPackagePrice, membershipPackagePrice) || other.membershipPackagePrice == membershipPackagePrice)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,userFullName,membershipPackageId,membershipPackageName,membershipPackagePrice,startDate,endDate,isActive,createdAt);

@override
String toString() {
  return 'UserMembershipResponse(id: $id, userId: $userId, userFullName: $userFullName, membershipPackageId: $membershipPackageId, membershipPackageName: $membershipPackageName, membershipPackagePrice: $membershipPackagePrice, startDate: $startDate, endDate: $endDate, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserMembershipResponseCopyWith<$Res> implements $UserMembershipResponseCopyWith<$Res> {
  factory _$UserMembershipResponseCopyWith(_UserMembershipResponse value, $Res Function(_UserMembershipResponse) _then) = __$UserMembershipResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, int userId, String userFullName, int membershipPackageId, String membershipPackageName, double membershipPackagePrice, DateTime startDate, DateTime endDate, bool isActive, DateTime createdAt
});




}
/// @nodoc
class __$UserMembershipResponseCopyWithImpl<$Res>
    implements _$UserMembershipResponseCopyWith<$Res> {
  __$UserMembershipResponseCopyWithImpl(this._self, this._then);

  final _UserMembershipResponse _self;
  final $Res Function(_UserMembershipResponse) _then;

/// Create a copy of UserMembershipResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? userFullName = null,Object? membershipPackageId = null,Object? membershipPackageName = null,Object? membershipPackagePrice = null,Object? startDate = null,Object? endDate = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_UserMembershipResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,userFullName: null == userFullName ? _self.userFullName : userFullName // ignore: cast_nullable_to_non_nullable
as String,membershipPackageId: null == membershipPackageId ? _self.membershipPackageId : membershipPackageId // ignore: cast_nullable_to_non_nullable
as int,membershipPackageName: null == membershipPackageName ? _self.membershipPackageName : membershipPackageName // ignore: cast_nullable_to_non_nullable
as String,membershipPackagePrice: null == membershipPackagePrice ? _self.membershipPackagePrice : membershipPackagePrice // ignore: cast_nullable_to_non_nullable
as double,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$PagedUserMembershipResponse {

 List<UserMembershipResponse> get items; int get totalCount; int get totalPages; int get currentPage; int get pageSize;
/// Create a copy of PagedUserMembershipResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagedUserMembershipResponseCopyWith<PagedUserMembershipResponse> get copyWith => _$PagedUserMembershipResponseCopyWithImpl<PagedUserMembershipResponse>(this as PagedUserMembershipResponse, _$identity);

  /// Serializes this PagedUserMembershipResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagedUserMembershipResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedUserMembershipResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class $PagedUserMembershipResponseCopyWith<$Res>  {
  factory $PagedUserMembershipResponseCopyWith(PagedUserMembershipResponse value, $Res Function(PagedUserMembershipResponse) _then) = _$PagedUserMembershipResponseCopyWithImpl;
@useResult
$Res call({
 List<UserMembershipResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class _$PagedUserMembershipResponseCopyWithImpl<$Res>
    implements $PagedUserMembershipResponseCopyWith<$Res> {
  _$PagedUserMembershipResponseCopyWithImpl(this._self, this._then);

  final PagedUserMembershipResponse _self;
  final $Res Function(PagedUserMembershipResponse) _then;

/// Create a copy of PagedUserMembershipResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<UserMembershipResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PagedUserMembershipResponse].
extension PagedUserMembershipResponsePatterns on PagedUserMembershipResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PagedUserMembershipResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PagedUserMembershipResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PagedUserMembershipResponse value)  $default,){
final _that = this;
switch (_that) {
case _PagedUserMembershipResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PagedUserMembershipResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PagedUserMembershipResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<UserMembershipResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PagedUserMembershipResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<UserMembershipResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)  $default,) {final _that = this;
switch (_that) {
case _PagedUserMembershipResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<UserMembershipResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,) {final _that = this;
switch (_that) {
case _PagedUserMembershipResponse() when $default != null:
return $default(_that.items,_that.totalCount,_that.totalPages,_that.currentPage,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PagedUserMembershipResponse implements PagedUserMembershipResponse {
  const _PagedUserMembershipResponse({required final  List<UserMembershipResponse> items, required this.totalCount, required this.totalPages, required this.currentPage, required this.pageSize}): _items = items;
  factory _PagedUserMembershipResponse.fromJson(Map<String, dynamic> json) => _$PagedUserMembershipResponseFromJson(json);

 final  List<UserMembershipResponse> _items;
@override List<UserMembershipResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int totalCount;
@override final  int totalPages;
@override final  int currentPage;
@override final  int pageSize;

/// Create a copy of PagedUserMembershipResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagedUserMembershipResponseCopyWith<_PagedUserMembershipResponse> get copyWith => __$PagedUserMembershipResponseCopyWithImpl<_PagedUserMembershipResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PagedUserMembershipResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagedUserMembershipResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedUserMembershipResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$PagedUserMembershipResponseCopyWith<$Res> implements $PagedUserMembershipResponseCopyWith<$Res> {
  factory _$PagedUserMembershipResponseCopyWith(_PagedUserMembershipResponse value, $Res Function(_PagedUserMembershipResponse) _then) = __$PagedUserMembershipResponseCopyWithImpl;
@override @useResult
$Res call({
 List<UserMembershipResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class __$PagedUserMembershipResponseCopyWithImpl<$Res>
    implements _$PagedUserMembershipResponseCopyWith<$Res> {
  __$PagedUserMembershipResponseCopyWithImpl(this._self, this._then);

  final _PagedUserMembershipResponse _self;
  final $Res Function(_PagedUserMembershipResponse) _then;

/// Create a copy of PagedUserMembershipResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_PagedUserMembershipResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<UserMembershipResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
