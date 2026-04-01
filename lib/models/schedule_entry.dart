import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/models/jsonapi.dart';
import 'package:studipassau/util/json.dart';

part 'schedule_entry.freezed.dart';
part 'schedule_entry.g.dart';

typedef ScheduleEntry = JsonApiResource<ScheduleEntryAttributes>;

@freezed
abstract class ScheduleEntryAttributes with _$ScheduleEntryAttributes {
  const ScheduleEntryAttributes._();

  @StringConverter()
  const factory ScheduleEntryAttributes({
    required String title,
    String? description,
    @HHMMIntConverter() required int start,
    @HHMMIntConverter() required int end,
    @JsonKey(name: 'weekday') required int rawWeekday,
    @JsonKey(name: 'color') required String colorId,
  }) = _ScheduleEntryAttributes;

  factory ScheduleEntryAttributes.fromJson(Map<String, dynamic> json) =>
      _$ScheduleEntryAttributesFromJson(json);

  /// Normalizes Sunday (0 in Stud.IP) to 7 for 1-based Monday indexing.
  int get weekday => rawWeekday == 0 ? 7 : rawWeekday;

  Color? get color => getColor(int.tryParse(colorId));
}
