import 'package:freezed_annotation/freezed_annotation.dart';
part 'event.freezed.dart';
part 'event.g.dart';

@freezed
abstract class RadarEvent with _$RadarEvent {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RadarEvent({
    required String id,
    required String title,
    required String description,
    required String contentLanguage,
    required String categorySlug,
    required int cityId,
    required String cityName,
    required String format,
    required String address,
    required DateTime startsAt,
    required DateTime endsAt,
    required String timezone,
    required String organizerName,
  }) = _RadarEvent;
  factory RadarEvent.fromJson(Map<String, dynamic> json) =>
      _$RadarEventFromJson(json);
}
