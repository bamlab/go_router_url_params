// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'person.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Person {

 String get name;@JsonKey(readValue: UrlParamsData.tryParse) int get age;@JsonKey(readValue: readObjectFromString, toJson: writeObjectToJson) PersonStatus? get status;
/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonCopyWith<Person> get copyWith => _$PersonCopyWithImpl<Person>(this as Person, _$identity);

  /// Serializes this Person to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Person&&(identical(other.name, name) || other.name == name)&&(identical(other.age, age) || other.age == age)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,age,status);

@override
String toString() {
  return 'Person(name: $name, age: $age, status: $status)';
}


}

/// @nodoc
abstract mixin class $PersonCopyWith<$Res>  {
  factory $PersonCopyWith(Person value, $Res Function(Person) _then) = _$PersonCopyWithImpl;
@useResult
$Res call({
 String name,@JsonKey(readValue: UrlParamsData.tryParse) int age,@JsonKey(readValue: readObjectFromString, toJson: writeObjectToJson) PersonStatus? status
});


$PersonStatusCopyWith<$Res>? get status;

}
/// @nodoc
class _$PersonCopyWithImpl<$Res>
    implements $PersonCopyWith<$Res> {
  _$PersonCopyWithImpl(this._self, this._then);

  final Person _self;
  final $Res Function(Person) _then;

/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? age = null,Object? status = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PersonStatus?,
  ));
}
/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonStatusCopyWith<$Res>? get status {
    if (_self.status == null) {
    return null;
  }

  return $PersonStatusCopyWith<$Res>(_self.status!, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}


/// Adds pattern-matching-related methods to [Person].
extension PersonPatterns on Person {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Person value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Person() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Person value)  $default,){
final _that = this;
switch (_that) {
case _Person():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Person value)?  $default,){
final _that = this;
switch (_that) {
case _Person() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name, @JsonKey(readValue: UrlParamsData.tryParse)  int age, @JsonKey(readValue: readObjectFromString, toJson: writeObjectToJson)  PersonStatus? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that.name,_that.age,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name, @JsonKey(readValue: UrlParamsData.tryParse)  int age, @JsonKey(readValue: readObjectFromString, toJson: writeObjectToJson)  PersonStatus? status)  $default,) {final _that = this;
switch (_that) {
case _Person():
return $default(_that.name,_that.age,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name, @JsonKey(readValue: UrlParamsData.tryParse)  int age, @JsonKey(readValue: readObjectFromString, toJson: writeObjectToJson)  PersonStatus? status)?  $default,) {final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that.name,_that.age,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Person extends Person {
  const _Person({required this.name, @JsonKey(readValue: UrlParamsData.tryParse) this.age = 0, @JsonKey(readValue: readObjectFromString, toJson: writeObjectToJson) this.status}): super._();
  factory _Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

@override final  String name;
@override@JsonKey(readValue: UrlParamsData.tryParse) final  int age;
@override@JsonKey(readValue: readObjectFromString, toJson: writeObjectToJson) final  PersonStatus? status;

/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonCopyWith<_Person> get copyWith => __$PersonCopyWithImpl<_Person>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Person&&(identical(other.name, name) || other.name == name)&&(identical(other.age, age) || other.age == age)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,age,status);

@override
String toString() {
  return 'Person(name: $name, age: $age, status: $status)';
}


}

/// @nodoc
abstract mixin class _$PersonCopyWith<$Res> implements $PersonCopyWith<$Res> {
  factory _$PersonCopyWith(_Person value, $Res Function(_Person) _then) = __$PersonCopyWithImpl;
@override @useResult
$Res call({
 String name,@JsonKey(readValue: UrlParamsData.tryParse) int age,@JsonKey(readValue: readObjectFromString, toJson: writeObjectToJson) PersonStatus? status
});


@override $PersonStatusCopyWith<$Res>? get status;

}
/// @nodoc
class __$PersonCopyWithImpl<$Res>
    implements _$PersonCopyWith<$Res> {
  __$PersonCopyWithImpl(this._self, this._then);

  final _Person _self;
  final $Res Function(_Person) _then;

/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? age = null,Object? status = freezed,}) {
  return _then(_Person(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PersonStatus?,
  ));
}

/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonStatusCopyWith<$Res>? get status {
    if (_self.status == null) {
    return null;
  }

  return $PersonStatusCopyWith<$Res>(_self.status!, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}


/// @nodoc
mixin _$PersonStatus {

@JsonKey(readValue: UrlParamsData.tryParse) bool get isActive; String get label;
/// Create a copy of PersonStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonStatusCopyWith<PersonStatus> get copyWith => _$PersonStatusCopyWithImpl<PersonStatus>(this as PersonStatus, _$identity);

  /// Serializes this PersonStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonStatus&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isActive,label);

@override
String toString() {
  return 'PersonStatus(isActive: $isActive, label: $label)';
}


}

/// @nodoc
abstract mixin class $PersonStatusCopyWith<$Res>  {
  factory $PersonStatusCopyWith(PersonStatus value, $Res Function(PersonStatus) _then) = _$PersonStatusCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: UrlParamsData.tryParse) bool isActive, String label
});




}
/// @nodoc
class _$PersonStatusCopyWithImpl<$Res>
    implements $PersonStatusCopyWith<$Res> {
  _$PersonStatusCopyWithImpl(this._self, this._then);

  final PersonStatus _self;
  final $Res Function(PersonStatus) _then;

/// Create a copy of PersonStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isActive = null,Object? label = null,}) {
  return _then(_self.copyWith(
isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonStatus].
extension PersonStatusPatterns on PersonStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonStatus value)  $default,){
final _that = this;
switch (_that) {
case _PersonStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonStatus value)?  $default,){
final _that = this;
switch (_that) {
case _PersonStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: UrlParamsData.tryParse)  bool isActive,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonStatus() when $default != null:
return $default(_that.isActive,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: UrlParamsData.tryParse)  bool isActive,  String label)  $default,) {final _that = this;
switch (_that) {
case _PersonStatus():
return $default(_that.isActive,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: UrlParamsData.tryParse)  bool isActive,  String label)?  $default,) {final _that = this;
switch (_that) {
case _PersonStatus() when $default != null:
return $default(_that.isActive,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PersonStatus extends PersonStatus {
  const _PersonStatus({@JsonKey(readValue: UrlParamsData.tryParse) this.isActive = true, this.label = 'Active'}): super._();
  factory _PersonStatus.fromJson(Map<String, dynamic> json) => _$PersonStatusFromJson(json);

@override@JsonKey(readValue: UrlParamsData.tryParse) final  bool isActive;
@override@JsonKey() final  String label;

/// Create a copy of PersonStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonStatusCopyWith<_PersonStatus> get copyWith => __$PersonStatusCopyWithImpl<_PersonStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonStatus&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isActive,label);

@override
String toString() {
  return 'PersonStatus(isActive: $isActive, label: $label)';
}


}

/// @nodoc
abstract mixin class _$PersonStatusCopyWith<$Res> implements $PersonStatusCopyWith<$Res> {
  factory _$PersonStatusCopyWith(_PersonStatus value, $Res Function(_PersonStatus) _then) = __$PersonStatusCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: UrlParamsData.tryParse) bool isActive, String label
});




}
/// @nodoc
class __$PersonStatusCopyWithImpl<$Res>
    implements _$PersonStatusCopyWith<$Res> {
  __$PersonStatusCopyWithImpl(this._self, this._then);

  final _PersonStatus _self;
  final $Res Function(_PersonStatus) _then;

/// Create a copy of PersonStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isActive = null,Object? label = null,}) {
  return _then(_PersonStatus(
isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
