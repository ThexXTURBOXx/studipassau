import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:dart_date/dart_date.dart' hide Date;
import 'package:flutter/material.dart' hide Interval;
import 'package:studipassau/bloc/blocs/schedule_bloc.dart';
import 'package:studipassau/bloc/events.dart';
import 'package:studipassau/bloc/repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/drawer/drawer.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/schedule/widgets/events.dart';
import 'package:supercharged/supercharged.dart';
import 'package:timetable/timetable.dart';

const ROUTE_SCHEDULE = '/schedule';

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
      maxDate: DateTimeTimetable.today() + 15.days,
    ),
  );

  final dateControllerContent = DateController(
    visibleRange: VisibleDateRange.days(
      1,
      minDate: DateTimeTimetable.today(),
      maxDate: DateTimeTimetable.today() + 15.days,
    ),
  );

  final timeController = TimeController(
    initialRange: TimeRange(8.hours - 30.minutes, 20.hours + 30.minutes),
  );

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  DateTime selected = DateTimeTimetable.today();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(
        (_) => _refreshIndicatorKey.currentState?.show());
    _scheduleBloc.stream.listen((event) {
      setState(() {});
    });
    dateControllerContent.date.addListener(() {
      setState(() {
        final date = dateControllerContent.date.value;
        animateHeaderTo(date);
        selected = date;
      });
    });
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).scheduleTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              _refreshIndicatorKey.currentState?.show();
            },
          ),
        ],
      ),
      drawer: StudiPassauDrawer(DrawerItem.SCHEDULE),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: refresh,
        child: TimetableTheme(
          data: TimetableThemeData(context,
              dateIndicatorStyleProvider: (date) => DateIndicatorStyle(
                    context,
                    date,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: getColor(context, date, Colors.transparent),
                    ),
                  ),
              weekdayIndicatorStyleProvider: (date) => WeekdayIndicatorStyle(
                    context,
                    date,
                    textStyle: theme.textTheme.caption!.copyWith(
                      color: getColor(context, date,
                          theme.colorScheme.background.mediumEmphasisOnColor),
                    ),
                  )),
          child: Column(
            children: [
              DatePageView(
                controller: dateControllerHeader,
                shrinkWrapInCrossAxis: true,
                builder: (context, date) => DateHeader(
                  date,
                  onTap: () =>
                      dateControllerContent.animateTo(date, vsync: this),
                  style: DateHeaderStyle(
                    context,
                    date,
                  ),
                ),
              ),
              Expanded(
                child: TimetableConfig<StudiPassauEvent>(
                  dateController: dateControllerContent,
                  timeController: timeController,
                  eventProvider: getEvents,
                  eventBuilder: (context, event) => StudiPassauEventWidget(
                    event,
                    onTap: () => onTap(event),
                  ),
                  allDayEventBuilder: (context, event, info) =>
                      StudiPassauAllDayEventWidget(
                    event,
                    info: info,
                    onTap: () => onTap(event),
                  ),
                  callbacks: const TimetableCallbacks(),
                  theme: TimetableThemeData(
                    context,
                    startOfWeek: DateTime.monday,
                  ),
                  child: MultiDateTimetableContent<StudiPassauEvent>(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<StudiPassauEvent> get events => _repo.schedule ?? <StudiPassauEvent>[];

  List<StudiPassauEvent> getEvents(Interval visible) {
    return events
        .where((e) => visible.includes(e.start) && visible.includes(e.end))
        .toList(growable: false);
  }

  Future<void> refresh() async {
    _scheduleBloc.add(FetchSchedule(_repo.userId));
    await _scheduleBloc.stream.firstWhere((state) => state.finished);
  }

  void onTap(StudiPassauEvent event) {
    print(event.start);
  }

  Color getColor(BuildContext context, DateTime date, Color defaultColor) {
    final theme = context.theme;
    final isSelected = date == selected;
    return date.isToday
        ? isSelected
            ? Colors.brown
            : theme.colorScheme.primary
        : isSelected
            ? Colors.green
            : defaultColor;
  }

  void animateHeaderTo(DateTime date) {
    final range = dateControllerHeader.visibleRange as DaysVisibleDateRange;
    final newDate = date - 3.days;
    dateControllerHeader.animateTo(
        range.minDate!.isAfter(newDate)
            ? range.minDate!
            : range.maxDate!.isBefore(date + 3.days)
                ? range.maxDate! - 6.days
                : newDate,
        vsync: this);
  }
}
