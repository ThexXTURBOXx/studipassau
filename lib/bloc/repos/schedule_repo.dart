import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studipassau/bloc/providers/studip_provider.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/pages/schedule/widgets/events.dart';
import 'package:studipassau/pages/settings/settings.dart';
import 'package:studipassau/util/json.dart';
import 'package:studipassau/util/jsonapi.dart';
import 'package:supercharged/supercharged.dart';
import 'package:timetable/timetable.dart';

part 'schedule_repo.freezed.dart';
part 'schedule_repo.g.dart';

class ScheduleRepo {
  final _studIPProvider = StudIPDataProvider();

  Future<List<StudiPassauEvent>> parseSchedule(String userId) async {
    final notFoundColor = Color(getPref(notFoundColorPref));
    final nonRegularColor = Color(getPref(nonRegularColorPref));
    final canceledColor = Color(getPref(canceledColorPref));

    final results = await Future.wait([
      _studIPProvider.apiGetJson('users/$userId/schedule'),
      _studIPProvider.apiGetJson('users/$userId/events?page[limit]=10000'),
      _studIPProvider.apiGetJson(
        'users/$userId/course-memberships?page[limit]=10000',
      ),
    ]);

    final schedule = _parseSchedule(results[0]);
    final events = parseCollection(
      results[1] as Map<String, dynamic>,
      (obj) => EventAttributes.fromJson(obj as Map<String, dynamic>),
    );
    final cms = parseCollection(
      results[2] as Map<String, dynamic>,
      (obj) => CourseMembershipAttributes.fromJson(obj as Map<String, dynamic>),
    );
    final eventsCache = <StudiPassauEvent>[];

    for (final event in events) {
      final eventRel = event.relationship('owner').first;
      final eventCourseId = eventRel.id;
      final eventAttrs = event.attributes;

      String? courseName;
      var color = notFoundColor;

      if (eventAttrs.isCancelled) {
        color = canceledColor;
      } else if (eventAttrs.categories.any(regularLectureCategories.contains)) {
        for (final course in schedule[eventAttrs.start.weekday - 1]) {
          final courseRel = course.relationship('owner').first;
          if (courseRel.type == eventRel.type &&
              (courseRel.type != 'courses' || courseRel.id == eventCourseId) &&
              _equalsCourseEventTime(
                course.attributes.start,
                eventAttrs.start,
              ) &&
              _equalsCourseEventTime(course.attributes.end, eventAttrs.end)) {
            final cm = cms.filter((cm) {
              final cmRel = cm.relationship('course').first;
              return cmRel.type == courseRel.type && cmRel.id == courseRel.id;
            }).firstOrNull;
            color = course.attributes.color ?? cm?.attributes.color ?? color;
            courseName = course.attributes.title;
            break;
          }
        }
      } else {
        color = nonRegularColor;
      }

      if (courseName == null || courseName.isEmpty) {
        try {
          final courseAttr = (await _studIPProvider.apiGetJson(
            'courses/$eventCourseId',
          ))['data']['attributes'];
          courseName = '${courseAttr['course-number']} ${courseAttr['title']}';
        } catch (e) {
          courseName = '';
        }
      }

      eventsCache.add(
        StudiPassauEvent(
          id: event.id,
          title: eventAttrs.title,
          course: courseName,
          description: eventAttrs.description,
          categories: eventAttrs.categories,
          room: eventAttrs.location,
          canceled: eventAttrs.isCancelled,
          start: eventAttrs.start,
          end: eventAttrs.end,
          backgroundColor: color,
        ),
      );
    }

    if (getPref(showScheduleOnlyPref)) {
      final today = DateTime.now().copyWith(
        second: 0,
        millisecond: 0,
        isUtc: true,
      );
      for (var i = 0; i < 7; i++) {
        for (final entry in schedule[i]) {
          if (entry.type != 'schedule-entries') continue;

          final first = (i - (today.weekday - 1) + 14) % 7;
          final start = _intTimeToDateTime(
            today + first.days,
            entry.attributes.start,
          );
          final end = _intTimeToDateTime(
            today + first.days,
            entry.attributes.end,
          );

          for (var j = 0; j <= eventDaysInFuture - first; j += 7) {
            eventsCache.add(
              StudiPassauEvent(
                id: entry.id,
                title: entry.attributes.title,
                course: '',
                description: entry.attributes.description,
                categories: const [],
                room: '',
                canceled: false,
                start: start + j.days,
                end: end + j.days,
                backgroundColor: entry.attributes.color ?? notFoundColor,
              ),
            );
          }
        }
      }
    }

    return eventsCache;
  }

  List<List<ScheduleEntry>> _parseSchedule(dynamic json) {
    final entries = parseCollection(
      json as Map<String, dynamic>,
      (obj) => ScheduleEntryAttributes.fromJson(obj as Map<String, dynamic>),
    );
    final schedule = List<List<ScheduleEntry>>.generate(7, (_) => []);
    for (final entry in entries) {
      schedule[entry.attributes.weekday - 1].add(entry);
    }
    return schedule;
  }

  bool _equalsCourseEventTime(int courseTime, DateTime eventTime) =>
      courseTime == eventTime.hour * 100 + eventTime.minute;

  DateTime _intTimeToDateTime(DateTime base, int time) =>
      base.copyWith(hour: time ~/ 100, minute: time % 100);
}

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

  Color? get color => getColor(int.parse(colorId));
}

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
    @JsonKey(name: 'is-cancelled') required bool isCancelled,
    @JsonKey(name: 'mkdate') required DateTime makeDate,
    @JsonKey(name: 'chdate') required DateTime changeDate,
  }) = _EventAttributes;

  factory EventAttributes.fromJson(Map<String, dynamic> json) =>
      _$EventAttributesFromJson(json);
}

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

  Color? get color => getColorOrNotFound(group + 1);
}
