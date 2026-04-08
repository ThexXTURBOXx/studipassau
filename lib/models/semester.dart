import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studipassau/models/jsonapi.dart';
import 'package:studipassau/util/json.dart';

part 'semester.freezed.dart';
part 'semester.g.dart';

typedef Semester = JsonApiResource<SemesterAttributes>;

@freezed
sealed class SemesterAttributes with _$SemesterAttributes {
  const SemesterAttributes._();

  @StringConverter()
  @DateTimeInLocalZoneConverter()
  const factory SemesterAttributes({
    required String title,
    required String token,
    required DateTime start,
    required DateTime end,
    @JsonKey(name: 'start-of-lectures') required DateTime startOfLectures,
    @JsonKey(name: 'end-of-lectures') required DateTime endOfLectures,
    required bool visible,
  }) = _SemesterAttributes;

  factory SemesterAttributes.fromJson(Map<String, dynamic> json) =>
      _$SemesterAttributesFromJson(json);
}
