import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:dart_date/dart_date.dart' hide Date;
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studipassau/bloc/cubits/login_cubit.dart';
import 'package:studipassau/bloc/cubits/schedule_cubit.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/drawer/drawer.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/schedule/widgets/events.dart';
import 'package:studipassau/pages/settings/settings.dart';
import 'package:supercharged/supercharged.dart';
import 'package:timetable/timetable.dart';

const routeSchedule = '/schedule';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<StatefulWidget> createState() => _SchedulePagePageState();
}

class _SchedulePagePageState extends State<SchedulePage>
    with TickerProviderStateMixin {
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
    if (getPref(scheduleAutoSyncPref)) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _refreshIndicatorKey.currentState?.show(),
      );
    }
    dateControllerContent.date.addListener(() {
      setState(() {
        final date = dateControllerContent.date.value;
        animateHeaderTo(date);
        selected = date;
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).scheduleTitle),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: S.of(context).refresh,
              onPressed: () {
                _refreshIndicatorKey.currentState?.show();
              },
            ),
          ],
        ),
        drawer: const StudiPassauDrawer(DrawerItem.schedule),
        body: BlocBuilder<LoginCubit, LoginState>(
          builder: (context, stateL) =>
              BlocBuilder<ScheduleCubit, ScheduleState>(
            builder: (context, stateS) => RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () => refresh(context, stateL.userId),
              child: TimetableTheme(
                data: TimetableThemeData(
                  context,
                  dateIndicatorStyleProvider: (date) => DateIndicatorStyle(
                    context,
                    date,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: getColor(context, date, Colors.transparent),
                    ),
                  ),
                  weekdayIndicatorStyleProvider: (date) =>
                      WeekdayIndicatorStyle(
                    context,
                    date,
                    textStyle: context.theme.textTheme.caption!.copyWith(
                      color: getColor(
                        context,
                        date,
                        context
                            .theme.colorScheme.background.mediumEmphasisOnColor,
                      ),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    DatePageView(
                      controller: dateControllerHeader,
                      shrinkWrapInCrossAxis: true,
                      builder: (context, date) => DateHeader(
                        date,
                        onTap: () => dateControllerContent.animateTo(
                          date,
                          vsync: this,
                        ),
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
                        eventProvider: (visible) =>
                            getEvents(stateS.events, visible),
                        eventBuilder: (context, event) =>
                            StudiPassauEventWidget(
                          event,
                          onTap: () => onTap(context, event),
                        ),
                        allDayEventBuilder: (context, event, info) =>
                            StudiPassauAllDayEventWidget(
                          event,
                          info: info,
                          onTap: () => onTap(context, event),
                        ),
                        callbacks: const TimetableCallbacks(),
                        theme: TimetableThemeData(
                          context,
                          startOfWeek: DateTime.monday,
                        ),
                        timeOverlayProvider: (ctx, date) => <TimeOverlay>[
                          TimeOverlay(
                            start: 8.hours,
                            end: 20.hours,
                            widget: const ColoredBox(color: Colors.black12),
                            position: TimeOverlayPosition.behindEvents,
                          ),
                        ],
                        child: MultiDateTimetableContent<StudiPassauEvent>(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  List<StudiPassauEvent> getEvents(
    List<StudiPassauEvent> events,
    Interval visible,
  ) =>
      events
          .where((e) => visible.includes(e.start) && visible.includes(e.end))
          .toList(growable: false);

  Future<void> refresh(BuildContext context, String userId) async {
    await context.read<ScheduleCubit>().fetchSchedule(userId);
  }

  void onTap(BuildContext ctx, StudiPassauEvent event) {
    final s = S.of(ctx);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Text(
          '${formatLine(s.course, event.course)}'
          '${formatLine(s.room, event.room)}'
          '${s.start}: ${formatHmTime(event.start)}\n'
          '${s.end}: ${formatHmTime(event.end)}\n'
          '${formatLine(s.description, event.description)}'
          '${formatLine(s.canceled, event.canceled ? s.yes : null)}',
        ),
        backgroundColor: event.backgroundColor,
        titleTextStyle: Theme.of(context)
            .textTheme
            .headline6!
            .copyWith(color: event.backgroundColor.highEmphasisOnColor),
        contentTextStyle: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: event.backgroundColor.highEmphasisOnColor),
      ),
    );
  }

  String formatLine(String title, String? entry) =>
      entry != null && entry.isNotEmpty ? '$title: $entry\n' : '';

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
      vsync: this,
    );
  }
}
