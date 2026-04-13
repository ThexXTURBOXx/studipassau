import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studipassau/pages/settings/settings.dart';
import 'package:studipassau/util/json.dart';
import 'package:timetable/timetable.dart';

part 'studipassau_event.freezed.dart';
part 'studipassau_event.g.dart';

@freezed
sealed class StudiPassauEvent with _$StudiPassauEvent implements Event {
  const StudiPassauEvent._();

  @StringConverter()
  const factory StudiPassauEvent({
    required String id,
    required String title,
    String? courseId,
    required String? description,
    required List<String> categories,
    required String room,
    @BoolConverter() required bool canceled,
    @ColorConverter() Color? backgroundColor,
    @DateTimeInSaveConverter() required DateTime start,
    @DateTimeInSaveConverter() required DateTime end,
  }) = _StudiPassauEvent;

  factory StudiPassauEvent.fromJson(Map<String, dynamic> json) =>
      _$StudiPassauEventFromJson(json);

  @override
  bool get isAllDay => end.difference(start).inDays >= 1;

  Color getBackgroundColor(Color? Function(String?) courseIdToColor) =>
      backgroundColor ??
      (canceled
          ? Color(getPref(canceledColorPref))
          : courseIdToColor(courseId)) ??
      Color(getPref(notFoundColorPref));
}
