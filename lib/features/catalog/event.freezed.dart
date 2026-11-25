// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RadarEvent {

 String get id; String get title; String get description; String get contentLanguage; String get categorySlug; int get cityId; String get cityName; String get format; String get address; DateTime get startsAt; DateTime get endsAt; String get timezone; String get organizerName;
/// Create a copy of RadarEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RadarEventCopyWith<RadarEvent> get copyWith => _$RadarEventCopyWithImpl<RadarEvent>(this as RadarEvent, _$identity);

  /// Serializes this RadarEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RadarEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.contentLanguage, contentLanguage) || other.contentLanguage == contentLanguage)&&(identical(other.categorySlug, categorySlug) || other.categorySlug == categorySlug)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.cityName, cityName) || other.cityName == cityName)&&(identical(other.format, format) || other.format == format)&&(identical(other.address, address) || other.address == address)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.organizerName, organizerName) || other.organizerName == organizerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,contentLanguage,categorySlug,cityId,cityName,format,address,startsAt,endsAt,timezone,organizerName);

@override
String toString() {
  return 'RadarEvent(id: $id, title: $title, description: $description, contentLanguage: $contentLanguage, categorySlug: $categorySlug, cityId: $cityId, cityName: $cityName, format: $format, address: $address, startsAt: $startsAt, endsAt: $endsAt, timezone: $timezone, organizerName: $organizerName)';
}


}

/// @nodoc
abstract mixin class $RadarEventCopyWith<$Res>  {
  factory $RadarEventCopyWith(RadarEvent value, $Res Function(RadarEvent) _then) = _$RadarEventCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String contentLanguage, String categorySlug, int cityId, String cityName, String format, String address, DateTime startsAt, DateTime endsAt, String timezone, String organizerName
});




}
/// @nodoc
class _$RadarEventCopyWithImpl<$Res>
    implements $RadarEventCopyWith<$Res> {
  _$RadarEventCopyWithImpl(this._self, this._then);

  final RadarEvent _self;
  final $Res Function(RadarEvent) _then;

/// Create a copy of RadarEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? contentLanguage = null,Object? categorySlug = null,Object? cityId = null,Object? cityName = null,Object? format = null,Object? address = null,Object? startsAt = null,Object? endsAt = null,Object? timezone = null,Object? organizerName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,contentLanguage: null == contentLanguage ? _self.contentLanguage : contentLanguage // ignore: cast_nullable_to_non_nullable
as String,categorySlug: null == categorySlug ? _self.categorySlug : categorySlug // ignore: cast_nullable_to_non_nullable
as String,cityId: null == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as int,cityName: null == cityName ? _self.cityName : cityName // ignore: cast_nullable_to_non_nullable
as String,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,organizerName: null == organizerName ? _self.organizerName : organizerName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RadarEvent].
extension RadarEventPatterns on RadarEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RadarEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RadarEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RadarEvent value)  $default,){
final _that = this;
switch (_that) {
case _RadarEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RadarEvent value)?  $default,){
final _that = this;
switch (_that) {
case _RadarEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String contentLanguage,  String categorySlug,  int cityId,  String cityName,  String format,  String address,  DateTime startsAt,  DateTime endsAt,  String timezone,  String organizerName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RadarEvent() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.contentLanguage,_that.categorySlug,_that.cityId,_that.cityName,_that.format,_that.address,_that.startsAt,_that.endsAt,_that.timezone,_that.organizerName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String contentLanguage,  String categorySlug,  int cityId,  String cityName,  String format,  String address,  DateTime startsAt,  DateTime endsAt,  String timezone,  String organizerName)  $default,) {final _that = this;
switch (_that) {
case _RadarEvent():
return $default(_that.id,_that.title,_that.description,_that.contentLanguage,_that.categorySlug,_that.cityId,_that.cityName,_that.format,_that.address,_that.startsAt,_that.endsAt,_that.timezone,_that.organizerName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String contentLanguage,  String categorySlug,  int cityId,  String cityName,  String format,  String address,  DateTime startsAt,  DateTime endsAt,  String timezone,  String organizerName)?  $default,) {final _that = this;
switch (_that) {
case _RadarEvent() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.contentLanguage,_that.categorySlug,_that.cityId,_that.cityName,_that.format,_that.address,_that.startsAt,_that.endsAt,_that.timezone,_that.organizerName);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _RadarEvent implements RadarEvent {
  const _RadarEvent({required this.id, required this.title, required this.description, required this.contentLanguage, required this.categorySlug, required this.cityId, required this.cityName, required this.format, required this.address, required this.startsAt, required this.endsAt, required this.timezone, required this.organizerName});
  factory _RadarEvent.fromJson(Map<String, dynamic> json) => _$RadarEventFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String contentLanguage;
@override final  String categorySlug;
@override final  int cityId;
@override final  String cityName;
@override final  String format;
@override final  String address;
@override final  DateTime startsAt;
@override final  DateTime endsAt;
@override final  String timezone;
@override final  String organizerName;

/// Create a copy of RadarEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RadarEventCopyWith<_RadarEvent> get copyWith => __$RadarEventCopyWithImpl<_RadarEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RadarEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RadarEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.contentLanguage, contentLanguage) || other.contentLanguage == contentLanguage)&&(identical(other.categorySlug, categorySlug) || other.categorySlug == categorySlug)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.cityName, cityName) || other.cityName == cityName)&&(identical(other.format, format) || other.format == format)&&(identical(other.address, address) || other.address == address)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.organizerName, organizerName) || other.organizerName == organizerName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,contentLanguage,categorySlug,cityId,cityName,format,address,startsAt,endsAt,timezone,organizerName);

@override
String toString() {
  return 'RadarEvent(id: $id, title: $title, description: $description, contentLanguage: $contentLanguage, categorySlug: $categorySlug, cityId: $cityId, cityName: $cityName, format: $format, address: $address, startsAt: $startsAt, endsAt: $endsAt, timezone: $timezone, organizerName: $organizerName)';
}


}

/// @nodoc
abstract mixin class _$RadarEventCopyWith<$Res> implements $RadarEventCopyWith<$Res> {
  factory _$RadarEventCopyWith(_RadarEvent value, $Res Function(_RadarEvent) _then) = __$RadarEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String contentLanguage, String categorySlug, int cityId, String cityName, String format, String address, DateTime startsAt, DateTime endsAt, String timezone, String organizerName
});




}
/// @nodoc
class __$RadarEventCopyWithImpl<$Res>
    implements _$RadarEventCopyWith<$Res> {
  __$RadarEventCopyWithImpl(this._self, this._then);

  final _RadarEvent _self;
  final $Res Function(_RadarEvent) _then;

/// Create a copy of RadarEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? contentLanguage = null,Object? categorySlug = null,Object? cityId = null,Object? cityName = null,Object? format = null,Object? address = null,Object? startsAt = null,Object? endsAt = null,Object? timezone = null,Object? organizerName = null,}) {
  return _then(_RadarEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,contentLanguage: null == contentLanguage ? _self.contentLanguage : contentLanguage // ignore: cast_nullable_to_non_nullable
as String,categorySlug: null == categorySlug ? _self.categorySlug : categorySlug // ignore: cast_nullable_to_non_nullable
as String,cityId: null == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as int,cityName: null == cityName ? _self.cityName : cityName // ignore: cast_nullable_to_non_nullable
as String,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,startsAt: null == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,organizerName: null == organizerName ? _self.organizerName : organizerName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
