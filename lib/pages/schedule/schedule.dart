import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:studipassau/bloc/blocs/data_bloc.dart';
import 'package:studipassau/bloc/events/data_event.dart';
import 'package:studipassau/bloc/repository/data_repo.dart';
import 'package:studipassau/bloc/repository/oauth_repo.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:timetable/timetable.dart';

class SchedulePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SchedulePagePageState();
}

class _SchedulePagePageState extends State<SchedulePage>
    with TickerProviderStateMixin {
  static final OAuthRepo oAuthRepo = OAuthRepo();
  static final DataRepo dataRepo = DataRepo(oAuthRepo.apiClient);
  final DataBloc _dataBloc = DataBloc(dataRepo);
  List<BasicEvent>? events;

  @override
  void initState() {
    super.initState();
    _dataBloc.add(FetchSchedule(oAuthRepo.userId));
    _dataBloc.stream.listen((event) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).scheduleTitle),
      ),
      body: TimetableConfig<BasicEvent>(
        eventProvider: getEvents,
        eventBuilder: (context, event) => BasicEventWidget(event),
        allDayEventBuilder: (context, event, info) =>
            BasicAllDayEventWidget(event, info: info),
        callbacks: const TimetableCallbacks(),
        theme: TimetableThemeData(
          context,
          startOfWeek: DateTime.monday,
        ),
        child: MultiDateTimetable<BasicEvent>(),
      ),
    );
  }

  List<BasicEvent> getEvents(Interval visibleRange) {
    return dataRepo.schedule ?? <BasicEvent>[];
  }
}
