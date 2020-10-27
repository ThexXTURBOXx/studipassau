import 'package:StudiPassau/bloc/blocs/data_bloc.dart';
import 'package:StudiPassau/bloc/repository/data_repo.dart';
import 'package:StudiPassau/bloc/repository/oauth_repo.dart';
import 'package:StudiPassau/pages/schedule/widgets/schedule_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';

class SchedulePage extends StatefulWidget {
  static final OAuthRepo oAuthRepo = OAuthRepo();
  static final DataRepo dataRepo = DataRepo(oAuthRepo.apiClient);

  @override
  State<StatefulWidget> createState() => _SchedulePagePageState();
}

class _SchedulePagePageState extends State<SchedulePage>
    with TickerProviderStateMixin {
  DataBloc _dataBloc;
  AnimationController _fadeController;
  Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _dataBloc = DataBloc(SchedulePage.dataRepo);
    //_dataBloc.add(FetchSchedule(SchedulePage.oAuthRepo.userId));
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    final provider = EventProvider.simpleStream(getSchedule(
        SchedulePage.dataRepo.apiClient, SchedulePage.oAuthRepo.userId));
    final controller = TimetableController(
      eventProvider: provider,
      initialDate: LocalDate.today(),
      visibleRange: const VisibleRange.week(),
      firstDayOfWeek: DayOfWeek.monday,
    );
    return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, 'schedule.title')),
        ),
        body: Timetable<BasicEvent>(
          controller: controller,
          eventBuilder: (event) => BasicEventWidget(event),
          allDayEventBuilder: (context, event, info) =>
              BasicAllDayEventWidget(event, info: info),
        )
        /*MaterialButton(
                child: const Text('ALLALA'),
                onPressed: () async {
                  getSchedule(SchedulePage.dataRepo.apiClient,
                          SchedulePage.oAuthRepo.userId)
                      .listen((event) => print(''));
                })*/
        /*SizeTransition(
              sizeFactor: _fadeAnimation,
              child: BlocBuilder(
                cubit: _dataBloc,
                builder: (context, state) {
                  _fadeController.reset();
                  _fadeController.forward();
                  if (state is NotFetched) {
                    return const Text('Not Fetched');
                  } else if (state is Fetching) {
                    return const Text('Fetching...');
                  } else if (state is Fetched) {
                    return Text(SchedulePage.dataRepo.schedule.toString());
                  } else if (state is AuthenticationError) {
                    return const Text('Auth Error');
                  } else {
                    return const Text('Should not happen');
                  }
                },
              ),
            ),*/
        );
  }
}
