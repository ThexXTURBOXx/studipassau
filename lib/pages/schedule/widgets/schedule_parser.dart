import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/pages/schedule/widgets/events.dart';

Future<List<StudiPassauEvent>> fetchSchedule(
  StudIPClient client,
  String userId,
) async {
  final dynamic jsonSchedule = await client.apiGetJson('user/$userId/schedule');
  final dynamic jsonEvents =
      await client.apiGetJson('user/$userId/events?limit=10000');
  final events = _parseEvents(jsonEvents);
  final schedule = _Schedule.fromJson(jsonSchedule);
  final eventsCache = <StudiPassauEvent>[];
  for (final event in events) {
    final start = DateTime.fromMillisecondsSinceEpoch(event.start, isUtc: true);
    final end = DateTime.fromMillisecondsSinceEpoch(event.end, isUtc: true);
    final eventCourseId = event.course.split('/').last;

    String? courseName;
    var color = notFoundColor;
    if (event.categories == regularLectureCategory) {
      for (final course in schedule.events[start.weekday - 1]!) {
        final courseId = course.id;
        if (courseId == eventCourseId &&
            equalsCourseEventTime(course.start, start) &&
            equalsCourseEventTime(course.end, end)) {
          color = course.color;
          courseName = course.content;
          break;
        }
      }
    } else {
      color = nonLectureColor;
    }

    if (courseName == null) {
      try {
        final courseResp = await client.apiGetJson('course/$eventCourseId');
        courseName = '${courseResp['number']} ${courseResp['title']}';
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
        start: start,
        end: end,
        backgroundColor: color,
      ),
    );
  }
  return eventsCache;
}

bool equalsCourseEventTime(int courseStart, DateTime eventStart) =>
    courseStart == eventStart.hour * 100 + eventStart.minute;

List<_Event> _parseEvents(json) {
  final collection = json['collection'];
  if (collection != null && collection is List) {
    return collection.map(_Event.fromJson).toList(growable: false);
  }
  return <_Event>[];
}

class _Event extends Equatable {
  final String id;
  final String course;
  final int start;
  final int end;
  final String title;
  final String description;
  final String categories;
  final String room;
  final bool canceled;

  const _Event({
    required this.id,
    required this.course,
    required this.start,
    required this.end,
    required this.title,
    required this.description,
    required this.categories,
    required this.room,
    required this.canceled,
  });

  factory _Event.fromJson(json) => _Event(
        id: json['event_id'].toString(),
        course: json['course'].toString(),
        start: location.translate(int.parse(json['start'].toString()) * 1000),
        end: location.translate(int.parse(json['end'].toString()) * 1000),
        title: json['title'].toString(),
        description: json['description'].toString(),
        categories: json['categories'].toString(),
        room: json['room'].toString(),
        canceled: json['canceled'].toString() == 'true',
      );

  @override
  List<Object> get props => [
        id,
        course,
        start,
        end,
        title,
        description,
        categories,
        room,
        canceled,
      ];

  @override
  bool get stringify => true;
}

class _Schedule extends Equatable {
  final List<List<_ScheduleEvent>?> events;

  const _Schedule({
    required this.events,
  });

  factory _Schedule.fromJson(json) {
    final events = List<List<_ScheduleEvent>>.generate(7, (index) => []);
    for (var i = 0; i < 7; i++) {
      final dynamic day = json['$i'];
      if (day != null && day is Map) {
        for (final event in (day as Map<String, dynamic>).entries) {
          events[i].add(_ScheduleEvent.fromJson(event.key, event.value));
        }
      }
    }
    return _Schedule(events: events);
  }

  @override
  List<Object> get props => [events];

  @override
  bool get stringify => true;
}

class _ScheduleEvent extends Equatable {
  final String id;
  final String internalId;
  final int start;
  final int end;
  final String content;
  final String title;
  final Color color;
  final String type;

  const _ScheduleEvent({
    required this.id,
    required this.internalId,
    required this.start,
    required this.end,
    required this.content,
    required this.title,
    required this.color,
    required this.type,
  });

  factory _ScheduleEvent.fromJson(String courseId, json) {
    final splitId = courseId.split('-');
    return _ScheduleEvent(
      id: splitId[0],
      internalId: splitId.length < 2 ? '' : splitId[1],
      start: int.parse(json['start'].toString()),
      end: int.parse(json['end'].toString()),
      content: json['content'].toString(),
      title: json['title'].toString(),
      color: getColor(int.parse(json['color'].toString())),
      type: json['type'].toString(),
    );
  }

  @override
  List<Object> get props => [
        id,
        internalId,
        start,
        end,
        content,
        title,
        color,
        type,
      ];

  @override
  bool get stringify => true;
}
