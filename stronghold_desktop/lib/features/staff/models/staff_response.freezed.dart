// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StaffResponse {

 int get id; String get firstName; String get lastName; String get email; String? get phone; String? get bio; String? get profileImageUrl; String get staffType; bool get isActive;
/// Create a copy of StaffResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffResponseCopyWith<StaffResponse> get copyWith => _$StaffResponseCopyWithImpl<StaffResponse>(this as StaffResponse, _$identity);

  /// Serializes this StaffResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.staffType, staffType) || other.staffType == staffType)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,email,phone,bio,profileImageUrl,staffType,isActive);

@override
String toString() {
  return 'StaffResponse(id: $id, firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, bio: $bio, profileImageUrl: $profileImageUrl, staffType: $staffType, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $StaffResponseCopyWith<$Res>  {
  factory $StaffResponseCopyWith(StaffResponse value, $Res Function(StaffResponse) _then) = _$StaffResponseCopyWithImpl;
@useResult
$Res call({
 int id, String firstName, String lastName, String email, String? phone, String? bio, String? profileImageUrl, String staffType, bool isActive
});




}
/// @nodoc
class _$StaffResponseCopyWithImpl<$Res>
    implements $StaffResponseCopyWith<$Res> {
  _$StaffResponseCopyWithImpl(this._self, this._then);

  final StaffResponse _self;
  final $Res Function(StaffResponse) _then;

/// Create a copy of StaffResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? phone = freezed,Object? bio = freezed,Object? profileImageUrl = freezed,Object? staffType = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,staffType: null == staffType ? _self.staffType : staffType // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffResponse].
extension StaffResponsePatterns on StaffResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffResponse value)  $default,){
final _that = this;
switch (_that) {
case _StaffResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffResponse value)?  $default,){
final _that = this;
switch (_that) {
case _StaffResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String firstName,  String lastName,  String email,  String? phone,  String? bio,  String? profileImageUrl,  String staffType,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffResponse() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.phone,_that.bio,_that.profileImageUrl,_that.staffType,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String firstName,  String lastName,  String email,  String? phone,  String? bio,  String? profileImageUrl,  String staffType,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _StaffResponse():
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.phone,_that.bio,_that.profileImageUrl,_that.staffType,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String firstName,  String lastName,  String email,  String? phone,  String? bio,  String? profileImageUrl,  String staffType,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _StaffResponse() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email,_that.phone,_that.bio,_that.profileImageUrl,_that.staffType,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffResponse implements StaffResponse {
  const _StaffResponse({required this.id, required this.firstName, required this.lastName, required this.email, this.phone, this.bio, this.profileImageUrl, required this.staffType, required this.isActive});
  factory _StaffResponse.fromJson(Map<String, dynamic> json) => _$StaffResponseFromJson(json);

@override final  int id;
@override final  String firstName;
@override final  String lastName;
@override final  String email;
@override final  String? phone;
@override final  String? bio;
@override final  String? profileImageUrl;
@override final  String staffType;
@override final  bool isActive;

/// Create a copy of StaffResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffResponseCopyWith<_StaffResponse> get copyWith => __$StaffResponseCopyWithImpl<_StaffResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.staffType, staffType) || other.staffType == staffType)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,email,phone,bio,profileImageUrl,staffType,isActive);

@override
String toString() {
  return 'StaffResponse(id: $id, firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, bio: $bio, profileImageUrl: $profileImageUrl, staffType: $staffType, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$StaffResponseCopyWith<$Res> implements $StaffResponseCopyWith<$Res> {
  factory _$StaffResponseCopyWith(_StaffResponse value, $Res Function(_StaffResponse) _then) = __$StaffResponseCopyWithImpl;
@override @useResult
$Res call({
 int id, String firstName, String lastName, String email, String? phone, String? bio, String? profileImageUrl, String staffType, bool isActive
});




}
/// @nodoc
class __$StaffResponseCopyWithImpl<$Res>
    implements _$StaffResponseCopyWith<$Res> {
  __$StaffResponseCopyWithImpl(this._self, this._then);

  final _StaffResponse _self;
  final $Res Function(_StaffResponse) _then;

/// Create a copy of StaffResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? email = null,Object? phone = freezed,Object? bio = freezed,Object? profileImageUrl = freezed,Object? staffType = null,Object? isActive = null,}) {
  return _then(_StaffResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,staffType: null == staffType ? _self.staffType : staffType // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PagedStaffResponse {

 List<StaffResponse> get items; int get totalCount; int get totalPages; int get currentPage; int get pageSize;
/// Create a copy of PagedStaffResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagedStaffResponseCopyWith<PagedStaffResponse> get copyWith => _$PagedStaffResponseCopyWithImpl<PagedStaffResponse>(this as PagedStaffResponse, _$identity);

  /// Serializes this PagedStaffResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagedStaffResponse&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedStaffResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class $PagedStaffResponseCopyWith<$Res>  {
  factory $PagedStaffResponseCopyWith(PagedStaffResponse value, $Res Function(PagedStaffResponse) _then) = _$PagedStaffResponseCopyWithImpl;
@useResult
$Res call({
 List<StaffResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class _$PagedStaffResponseCopyWithImpl<$Res>
    implements $PagedStaffResponseCopyWith<$Res> {
  _$PagedStaffResponseCopyWithImpl(this._self, this._then);

  final PagedStaffResponse _self;
  final $Res Function(PagedStaffResponse) _then;

/// Create a copy of PagedStaffResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<StaffResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PagedStaffResponse].
extension PagedStaffResponsePatterns on PagedStaffResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PagedStaffResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PagedStaffResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PagedStaffResponse value)  $default,){
final _that = this;
switch (_that) {
case _PagedStaffResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PagedStaffResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PagedStaffResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<StaffResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PagedStaffResponse() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<StaffResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)  $default,) {final _that = this;
switch (_that) {
case _PagedStaffResponse():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<StaffResponse> items,  int totalCount,  int totalPages,  int currentPage,  int pageSize)?  $default,) {final _that = this;
switch (_that) {
case _PagedStaffResponse() when $default != null:
return $default(_that.items,_that.totalCount,_that.totalPages,_that.currentPage,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PagedStaffResponse implements PagedStaffResponse {
  const _PagedStaffResponse({required final  List<StaffResponse> items, required this.totalCount, required this.totalPages, required this.currentPage, required this.pageSize}): _items = items;
  factory _PagedStaffResponse.fromJson(Map<String, dynamic> json) => _$PagedStaffResponseFromJson(json);

 final  List<StaffResponse> _items;
@override List<StaffResponse> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int totalCount;
@override final  int totalPages;
@override final  int currentPage;
@override final  int pageSize;

/// Create a copy of PagedStaffResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagedStaffResponseCopyWith<_PagedStaffResponse> get copyWith => __$PagedStaffResponseCopyWithImpl<_PagedStaffResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PagedStaffResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagedStaffResponse&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),totalCount,totalPages,currentPage,pageSize);

@override
String toString() {
  return 'PagedStaffResponse(items: $items, totalCount: $totalCount, totalPages: $totalPages, currentPage: $currentPage, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$PagedStaffResponseCopyWith<$Res> implements $PagedStaffResponseCopyWith<$Res> {
  factory _$PagedStaffResponseCopyWith(_PagedStaffResponse value, $Res Function(_PagedStaffResponse) _then) = __$PagedStaffResponseCopyWithImpl;
@override @useResult
$Res call({
 List<StaffResponse> items, int totalCount, int totalPages, int currentPage, int pageSize
});




}
/// @nodoc
class __$PagedStaffResponseCopyWithImpl<$Res>
    implements _$PagedStaffResponseCopyWith<$Res> {
  __$PagedStaffResponseCopyWithImpl(this._self, this._then);

  final _PagedStaffResponse _self;
  final $Res Function(_PagedStaffResponse) _then;

/// Create a copy of PagedStaffResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalCount = null,Object? totalPages = null,Object? currentPage = null,Object? pageSize = null,}) {
  return _then(_PagedStaffResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<StaffResponse>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
