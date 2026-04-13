import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/models/jsonapi.dart';
import 'package:studipassau/util/json.dart';

part 'course_membership.freezed.dart';
part 'course_membership.g.dart';

typedef CourseMembership = JsonApiResource<CourseMembershipAttributes>;

@freezed
abstract class CourseMembershipAttributes with _$CourseMembershipAttributes {
  const CourseMembershipAttributes._();

  @StringConverter()
  @DateTimeInLocalZoneConverter()
  const factory CourseMembershipAttributes({
    required String permission,
    required int position,
    required int group,
    @JsonKey(name: 'mkdate') required DateTime makeDate,
    required String label,
    required String visible,
    String? comment,
  }) = _CourseMembershipAttributes;

  factory CourseMembershipAttributes.fromJson(Map<String, dynamic> json) =>
      _$CourseMembershipAttributesFromJson(json);

  Color get color => getColorOrNotFound(group + 1);
}
