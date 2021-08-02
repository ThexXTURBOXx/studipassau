import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:studipassau/bloc/blocs/schedule_bloc.dart';
import 'package:studipassau/bloc/events.dart';
import 'package:studipassau/bloc/repo.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:supercharged/supercharged.dart';
import 'package:timetable/timetable.dart';

class SchedulePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SchedulePagePageState();
}

class _SchedulePagePageState extends State<SchedulePage>
    with TickerProviderStateMixin {
  static final StudiPassauRepo _repo = StudiPassauRepo();
  final ScheduleBloc _scheduleBloc = ScheduleBloc();
  final dateControllerHeader = DateController(
    visibleRange: VisibleDateRange.days(
      7,
      minDate: DateTimeTimetable.today(),
      maxDate: DateTimeTimetable.today().add(9.days),
    ),
  );
  final dateControllerContent = DateController(
    visibleRange: VisibleDateRange.days(
      1,
      minDate: DateTimeTimetable.today(),
      maxDate: DateTimeTimetable.today().add(15.days),
    ),
  );
  final timeController = TimeController(
    initialRange: TimeRange(8.hours - 30.minutes, 20.hours + 30.minutes),
  );

  List<BasicEvent> get events => _repo.schedule ?? <BasicEvent>[];

  @override
  void initState() {
    super.initState();
    _scheduleBloc.stream.listen((event) {
      setState(() {});
    });
    _scheduleBloc.add(FetchSchedule(_repo.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).scheduleTitle),
        ),
        body: Column(
          children: [
            DatePageView(
              controller: dateControllerHeader,
              shrinkWrapInCrossAxis: true,
              builder: (context, date) => DateHeader(
                date,
                onTap: () => dateControllerContent.animateTo(date, vsync: this),
                style: DateHeaderStyle(
                  context,
                  date,
                ),
              ),
            ),
            Expanded(
              child: TimetableConfig<BasicEvent>(
                dateController: dateControllerContent,
                timeController: timeController,
                eventProvider: getEvents,
                eventBuilder: (context, event) => BasicEventWidget(
                  event,
                  onTap: () => onTap(event),
                ),
                allDayEventBuilder: (context, event, info) =>
                    BasicAllDayEventWidget(
                  event,
                  info: info,
                  onTap: () => onTap(event),
                ),
                callbacks: const TimetableCallbacks(),
                theme: TimetableThemeData(
                  context,
                  startOfWeek: DateTime.monday,
                ),
                child: MultiDateTimetableContent<BasicEvent>(),
              ),
            ),
          ],
        ));
  }

  List<BasicEvent> getEvents(Interval visible) {
    return events
        .where((e) => visible.includes(e.start) && visible.includes(e.end))
        .toList(growable: false);
  }

  void onTap(BasicEvent event) {
    print(event.start);
  }
}
