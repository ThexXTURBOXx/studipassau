import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:studipassau/bloc/providers/studip_provider.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/pages/schedule/widgets/events.dart';
import 'package:studipassau/pages/settings/settings.dart';
import 'package:supercharged/supercharged.dart';
import 'package:timetable/timetable.dart';

class ScheduleRepo {
  final _studIPProvider = StudIPDataProvider();

  Future<List<StudiPassauEvent>> parseSchedule(String userId) async {
    final notFoundColor = Color(getPref(notFoundColorPref));
    final nonRegularColor = Color(getPref(nonRegularColorPref));
    final canceledColor = Color(getPref(canceledColorPref));

    final dynamic jsonSchedule = await _studIPProvider.apiGetJson(
      'users/$userId/schedule',
    );
    final dynamic jsonEvents = await _studIPProvider.apiGetJson(
      'users/$userId/events?page[limit]=10000',
    );
    final dynamic jsonCMs = await _studIPProvider.apiGetJson(
      'users/$userId/course-memberships?page[limit]=10000',
    );
    final events = _parseEvents(jsonEvents);
    final schedule = _Schedule.fromJson(jsonSchedule).events;
    final cms = _parseCourseMemberships(jsonCMs);
    final eventsCache = <StudiPassauEvent>[];

    for (final event in events) {
      final eventCourseId = event.ownerId;

      String? courseName;
      var color = notFoundColor;
      if (event.canceled) {
        color = canceledColor;
      } else if (event.categories.any(regularLectureCategories.contains)) {
        for (final course
            in schedule[event.start.weekday - 1] ?? <_ScheduleEvent>[]) {
          if (course.ownerType == event.ownerType &&
              (course.ownerType != 'courses' ||
                  course.ownerId == eventCourseId) &&
              _equalsCourseEventTime(course.start, event.start) &&
              _equalsCourseEventTime(course.end, event.end)) {
            final cm =
                cms
                    .filter(
                      (cm) =>
                          cm.courseType == course.ownerType &&
                          cm.courseId == course.ownerId,
                    )
                    .firstOrNull;
            color = course.color ?? cm?.color ?? color;
            courseName = course.title;
            break;
          }
        }
      } else {
        color = nonRegularColor;
      }

      if (courseName == null || courseName.isEmpty) {
        try {
          final courseAttr =
              (await _studIPProvider.apiGetJson(
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
          title: event.title,
          course: courseName,
          description: event.description,
          categories: event.categories,
          room: event.room,
          canceled: event.canceled,
          start: event.start,
          end: event.end,
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
        final day = schedule[i];
        for (final event in day ?? <_ScheduleEvent>[]) {
          if (event.type == 'schedule-entries') {
            final first = (i - (today.weekday - 1) + 14) % 7;
            final hourStart = (event.start / 100).floor();
            final minuteStart = event.start % 100;
            final hourEnd = (event.end / 100).floor();
            final minuteEnd = event.end % 100;
            final start = (today + first.days).copyWith(
              hour: hourStart,
              minute: minuteStart,
            );
            final end = (today + first.days).copyWith(
              hour: hourEnd,
              minute: minuteEnd,
            );
            for (var j = 0; j <= eventDaysInFuture - first; j += 7) {
              eventsCache.add(
                StudiPassauEvent(
                  id: event.id,
                  title: event.title,
                  course: '',
                  description: event.description,
                  categories: [],
                  room: '',
                  canceled: false,
                  start: start + j.days,
                  end: end + j.days,
                  backgroundColor: event.color ?? notFoundColor,
                ),
              );
            }
          }
        }
      }
    }

    return eventsCache;
  }

  bool _equalsCourseEventTime(int courseTime, DateTime eventTime) =>
      courseTime == eventTime.hour * 100 + eventTime.minute;

  List<_Event> _parseEvents(json) {
    final data = json['data'];
    if (data != null && data is List) {
      return data.map(_Event.fromJson).toList(growable: false);
    }
    return <_Event>[];
  }

  List<_CourseMembership> _parseCourseMemberships(json) {
    final data = json['data'];
    if (data != null && data is List) {
      return data.map(_CourseMembership.fromJson).toList(growable: false);
    }
    return <_CourseMembership>[];
  }
}

class _Event extends Equatable {
  const _Event({
    required this.id,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.categories,
    required this.room,
    required this.ownerType,
    required this.ownerId,
  });

  factory _Event.fromJson(json) => _Event(
    id: json['id'].toString(),
    title: json['attributes']['title'].toString(),
    description: json['attributes']['description'].toString(),
    start: parseInLocalZone(json['attributes']['start'].toString()),
    end: parseInLocalZone(json['attributes']['end'].toString()),
    categories: (json['attributes']['categories'] as List<dynamic>)
        .map((c) => c.toString())
        .toList(growable: false),
    room: (json['attributes']['location'] ?? '').toString(),
    ownerType: json['relationships']['owner']['data']['type'].toString(),
    ownerId: json['relationships']['owner']['data']['id'].toString(),
  );

  final String id;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final List<String> categories;
  final String room;
  final String ownerType;
  final String ownerId;

  bool get canceled => categories.isEmpty || title.endsWith(' (fällt aus)');

  @override
  List<Object> get props => [
    id,
    title,
    description,
    start,
    end,
    categories,
    room,
    ownerType,
    ownerId,
  ];
}

class _Schedule extends Equatable {
  const _Schedule({required this.events});

  factory _Schedule.fromJson(json) {
    final events = List<List<_ScheduleEvent>>.generate(7, (index) => []);
    for (final e in json['data']) {
      final event = _ScheduleEvent.fromJson(e);
      events[event.weekday - 1].add(event);
    }
    return _Schedule(events: events);
  }

  final List<List<_ScheduleEvent>?> events;

  @override
  List<Object> get props => [events];
}

class _ScheduleEvent extends Equatable {
  const _ScheduleEvent({
    required this.type,
    required this.id,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.weekday,
    required this.color,
    required this.ownerType,
    required this.ownerId,
  });

  factory _ScheduleEvent.fromJson(json) => _ScheduleEvent(
    type: json['type'].toString(),
    id: json['id'].toString(),
    title: json['attributes']['title'].toString(),
    description: json['attributes']['description'].toString(),
    start: int.parse(
      json['attributes']['start'].toString().replaceAll(':', ''),
    ),
    end: int.parse(json['attributes']['end'].toString().replaceAll(':', '')),
    weekday: _normalizeWeekday(
      int.parse(json['attributes']['weekday'].toString()),
    ),
    color: getColor(int.parse(json['attributes']['color']?.toString() ?? '0')),
    ownerType: json['relationships']['owner']['data']['type'].toString(),
    ownerId: json['relationships']['owner']['data']['id'].toString(),
  );

  static int _normalizeWeekday(int weekday) => weekday == 0 ? 7 : weekday;

  final String type;
  final String id;
  final String title;
  final String description;
  final int start;
  final int end;
  final int weekday;
  final Color? color;
  final String ownerType;
  final String ownerId;

  @override
  List<Object> get props => [
    type,
    id,
    title,
    description,
    start,
    end,
    weekday,
    ownerType,
    ownerId,
  ];
}

class _CourseMembership extends Equatable {
  const _CourseMembership({
    required this.type,
    required this.id,
    required this.color,
    required this.courseType,
    required this.courseId,
  });

  factory _CourseMembership.fromJson(json) => _CourseMembership(
    type: json['type'].toString(),
    id: json['id'].toString(),
    color: getColorOrNotFound(
      int.parse(json['attributes']['group']?.toString() ?? '0') + 1,
    ),
    courseType: json['relationships']['course']['data']['type'].toString(),
    courseId: json['relationships']['course']['data']['id'].toString(),
  );

  final String type;
  final String id;
  final Color color;
  final String courseType;
  final String courseId;

  @override
  List<Object> get props => [type, id, color, courseType, courseId];
}
