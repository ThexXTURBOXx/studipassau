import 'package:studipassau/bloc/providers/studip_provider.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/models/event.dart';
import 'package:studipassau/models/jsonapi.dart';
import 'package:studipassau/models/schedule_entry.dart';
import 'package:studipassau/models/studipassau_event.dart';
import 'package:studipassau/pages/settings/settings.dart';
import 'package:supercharged/supercharged.dart';
import 'package:timetable/timetable.dart';

class ScheduleRepo {
  final _studIPProvider = StudIPDataProvider();

  Future<List<StudiPassauEvent>> parseSchedule(String userId) async {
    final showScheduleOnly = getPref(showScheduleOnlyPref);

    final results = await Future.wait([
      _studIPProvider.apiGetJson('users/$userId/schedule'),
      _studIPProvider.apiGetJson('users/$userId/events?page[limit]=10000'),
    ]);

    final schedule = _parseSchedule(results[0]);
    final events = parseCollection(
      results[1] as Map<String, dynamic>,
      (obj) => EventAttributes.fromJson(obj as Map<String, dynamic>),
    );
    final eventsCache = <StudiPassauEvent>[];

    for (final event in events) {
      final eventRel = event.relationship('owner').first;
      final eventAttrs = event.attributes;

      eventsCache.add(
        StudiPassauEvent(
          id: event.id,
          title: eventAttrs.title,
          courseId: eventRel.id,
          description: eventAttrs.description,
          categories: eventAttrs.categories,
          room: eventAttrs.location,
          canceled: eventAttrs.isCancelled,
          start: eventAttrs.start,
          end: eventAttrs.end,
        ),
      );
    }

    if (showScheduleOnly) {
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
                description: entry.attributes.description,
                categories: const [],
                room: '',
                canceled: false,
                start: start + j.days,
                end: end + j.days,
                backgroundColor: entry.attributes.color,
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

  DateTime _intTimeToDateTime(DateTime base, int time) =>
      base.copyWith(hour: time ~/ 100, minute: time % 100);
}
