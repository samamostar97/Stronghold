// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'eligible_member_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EligibleMemberResponse {

 int get userId; String get userFullName; String get membershipPackageName;
/// Create a copy of EligibleMemberResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EligibleMemberResponseCopyWith<EligibleMemberResponse> get copyWith => _$EligibleMemberResponseCopyWithImpl<EligibleMemberResponse>(this as EligibleMemberResponse, _$identity);

  /// Serializes this EligibleMemberResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EligibleMemberResponse&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userFullName, userFullName) || other.userFullName == userFullName)&&(identical(other.membershipPackageName, membershipPackageName) || other.membershipPackageName == membershipPackageName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,userFullName,membershipPackageName);

@override
String toString() {
  return 'EligibleMemberResponse(userId: $userId, userFullName: $userFullName, membershipPackageName: $membershipPackageName)';
}


}

/// @nodoc
abstract mixin class $EligibleMemberResponseCopyWith<$Res>  {
  factory $EligibleMemberResponseCopyWith(EligibleMemberResponse value, $Res Function(EligibleMemberResponse) _then) = _$EligibleMemberResponseCopyWithImpl;
@useResult
$Res call({
 int userId, String userFullName, String membershipPackageName
});




}
/// @nodoc
class _$EligibleMemberResponseCopyWithImpl<$Res>
    implements $EligibleMemberResponseCopyWith<$Res> {
  _$EligibleMemberResponseCopyWithImpl(this._self, this._then);

  final EligibleMemberResponse _self;
  final $Res Function(EligibleMemberResponse) _then;

/// Create a copy of EligibleMemberResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? userFullName = null,Object? membershipPackageName = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,userFullName: null == userFullName ? _self.userFullName : userFullName // ignore: cast_nullable_to_non_nullable
as String,membershipPackageName: null == membershipPackageName ? _self.membershipPackageName : membershipPackageName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EligibleMemberResponse].
extension EligibleMemberResponsePatterns on EligibleMemberResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EligibleMemberResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EligibleMemberResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EligibleMemberResponse value)  $default,){
final _that = this;
switch (_that) {
case _EligibleMemberResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EligibleMemberResponse value)?  $default,){
final _that = this;
switch (_that) {
case _EligibleMemberResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int userId,  String userFullName,  String membershipPackageName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EligibleMemberResponse() when $default != null:
return $default(_that.userId,_that.userFullName,_that.membershipPackageName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int userId,  String userFullName,  String membershipPackageName)  $default,) {final _that = this;
switch (_that) {
case _EligibleMemberResponse():
return $default(_that.userId,_that.userFullName,_that.membershipPackageName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int userId,  String userFullName,  String membershipPackageName)?  $default,) {final _that = this;
switch (_that) {
case _EligibleMemberResponse() when $default != null:
return $default(_that.userId,_that.userFullName,_that.membershipPackageName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EligibleMemberResponse implements EligibleMemberResponse {
  const _EligibleMemberResponse({required this.userId, required this.userFullName, required this.membershipPackageName});
  factory _EligibleMemberResponse.fromJson(Map<String, dynamic> json) => _$EligibleMemberResponseFromJson(json);

@override final  int userId;
@override final  String userFullName;
@override final  String membershipPackageName;

/// Create a copy of EligibleMemberResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EligibleMemberResponseCopyWith<_EligibleMemberResponse> get copyWith => __$EligibleMemberResponseCopyWithImpl<_EligibleMemberResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EligibleMemberResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EligibleMemberResponse&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userFullName, userFullName) || other.userFullName == userFullName)&&(identical(other.membershipPackageName, membershipPackageName) || other.membershipPackageName == membershipPackageName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,userFullName,membershipPackageName);

@override
String toString() {
  return 'EligibleMemberResponse(userId: $userId, userFullName: $userFullName, membershipPackageName: $membershipPackageName)';
}


}

/// @nodoc
abstract mixin class _$EligibleMemberResponseCopyWith<$Res> implements $EligibleMemberResponseCopyWith<$Res> {
  factory _$EligibleMemberResponseCopyWith(_EligibleMemberResponse value, $Res Function(_EligibleMemberResponse) _then) = __$EligibleMemberResponseCopyWithImpl;
@override @useResult
$Res call({
 int userId, String userFullName, String membershipPackageName
});




}
/// @nodoc
class __$EligibleMemberResponseCopyWithImpl<$Res>
    implements _$EligibleMemberResponseCopyWith<$Res> {
  __$EligibleMemberResponseCopyWithImpl(this._self, this._then);

  final _EligibleMemberResponse _self;
  final $Res Function(_EligibleMemberResponse) _then;

/// Create a copy of EligibleMemberResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? userFullName = null,Object? membershipPackageName = null,}) {
  return _then(_EligibleMemberResponse(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,userFullName: null == userFullName ? _self.userFullName : userFullName // ignore: cast_nullable_to_non_nullable
as String,membershipPackageName: null == membershipPackageName ? _self.membershipPackageName : membershipPackageName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
