import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:studip/studip.dart';
import 'package:timetable/timetable.dart';

Future<List<BasicEvent>> fetchSchedule(
    StudIPClient client, String userId) async {
  final dynamic jsonSchedule = await client.apiGetJson('user/$userId/schedule');
  final dynamic jsonEvents =
      await client.apiGetJson('user/$userId/events?limit=10000');
  final events = _parseEvents(jsonEvents);
  final schedule = _Schedule.fromJson(jsonSchedule);
  final eventsCache = <BasicEvent>[];
  for (final event in events) {
    eventsCache.add(BasicEvent(
      id: event.id,
      title: event.title,
      start: DateTime.fromMillisecondsSinceEpoch(event.start),
      end: DateTime.fromMillisecondsSinceEpoch(event.end),
      backgroundColor: const Color(0xffaaaa00),
    ));
  }
  return eventsCache;
}

List<_Event> _parseEvents(dynamic json) {
  final events = <_Event>[];
  final collection = json['collection'];
  if (collection != null && collection is List) {
    for (final event in collection) {
      events.add(_Event.fromJson(event));
    }
  }
  return events;
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

  factory _Event.fromJson(dynamic json) {
    return _Event(
      id: json['event_id'].toString(),
      course: json['course'].toString(),
      start: int.parse(json['start'].toString()) * 1000,
      end: int.parse(json['end'].toString()) * 1000,
      title: json['title'].toString(),
      description: json['description'].toString(),
      categories: json['categories'].toString(),
      room: json['room'].toString(),
      canceled: json['canceled'].toString() == 'true',
    );
  }

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

  factory _Schedule.fromJson(dynamic json) {
    final events = List<List<_ScheduleEvent>?>.generate(7, (index) => null);
    for (var i = 0; i < 7; i++) {
      final dynamic day = json['$i'];
      events[i] = [];
      if (day != null && day is Map) {
        for (final event in (day as Map<String, dynamic>).entries) {
          events[i]!.add(_ScheduleEvent.fromJson(event.key, event.value));
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
  final int color;
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

  factory _ScheduleEvent.fromJson(String courseId, dynamic json) {
    final splitId = courseId.split('-');
    return _ScheduleEvent(
      id: splitId[0],
      internalId: splitId[1],
      start: int.parse(json['start'].toString()),
      end: int.parse(json['end'].toString()),
      content: json['content'].toString(),
      title: json['title'].toString(),
      color: int.parse(json['color'].toString()),
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
