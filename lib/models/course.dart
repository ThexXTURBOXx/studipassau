import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studipassau/models/jsonapi.dart';
import 'package:studipassau/util/json.dart';

part 'course.freezed.dart';
part 'course.g.dart';

typedef Course = JsonApiResource<CourseAttributes>;

@freezed
sealed class CourseAttributes with _$CourseAttributes {
  const CourseAttributes._();

  @StringConverter()
  const factory CourseAttributes({
    @JsonKey(name: 'course-number') String? courseNumber,
    required String title,
    String? subtitle,
    @JsonKey(name: 'course-type') required int courseType,
    String? description,
    String? location,
    String? miscellaneous,
  }) = _CourseAttributes;

  factory CourseAttributes.fromJson(Map<String, dynamic> json) =>
      _$CourseAttributesFromJson(json);

  String get formattedTitle => courseNumber?.isEmpty ?? true
      ? title.trim()
      : '${courseNumber!.trim()} ${title.trim()}';
}
