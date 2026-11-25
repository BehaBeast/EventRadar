// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RadarEvent _$RadarEventFromJson(Map<String, dynamic> json) => _RadarEvent(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  contentLanguage: json['content_language'] as String,
  categorySlug: json['category_slug'] as String,
  cityId: (json['city_id'] as num).toInt(),
  cityName: json['city_name'] as String,
  format: json['format'] as String,
  address: json['address'] as String,
  startsAt: DateTime.parse(json['starts_at'] as String),
  endsAt: DateTime.parse(json['ends_at'] as String),
  timezone: json['timezone'] as String,
  organizerName: json['organizer_name'] as String,
);

Map<String, dynamic> _$RadarEventToJson(_RadarEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'content_language': instance.contentLanguage,
      'category_slug': instance.categorySlug,
      'city_id': instance.cityId,
      'city_name': instance.cityName,
      'format': instance.format,
      'address': instance.address,
      'starts_at': instance.startsAt.toIso8601String(),
      'ends_at': instance.endsAt.toIso8601String(),
      'timezone': instance.timezone,
      'organizer_name': instance.organizerName,
    };
