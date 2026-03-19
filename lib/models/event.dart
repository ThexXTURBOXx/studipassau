import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studipassau/models/jsonapi.dart';
import 'package:studipassau/util/json.dart';

part 'event.freezed.dart';
part 'event.g.dart';

typedef Event = JsonApiResource<EventAttributes>;

@freezed
abstract class EventAttributes with _$EventAttributes {
  const EventAttributes._();

  @StringConverter()
  @DateTimeInLocalZoneConverter()
  const factory EventAttributes({
    required String title,
    required String description,
    required DateTime start,
    required DateTime end,
    required List<String> categories,
    required String location,
    @JsonKey(name: 'is-cancelled', defaultValue: false)
    required bool isCancelled,
    @JsonKey(name: 'mkdate') required DateTime makeDate,
    @JsonKey(name: 'chdate') required DateTime changeDate,
  }) = _EventAttributes;

  factory EventAttributes.fromJson(Map<String, dynamic> json) =>
      _$EventAttributesFromJson(json);
}
