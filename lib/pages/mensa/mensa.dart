import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:openmensa/openmensa.dart';
import 'package:studipassau/bloc/blocs/mensa_bloc.dart';
import 'package:studipassau/bloc/events.dart';
import 'package:studipassau/bloc/repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/drawer/drawer.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:timetable/timetable.dart';

const routeMensa = '/mensa';

class MensaPage extends StatefulWidget {
  const MensaPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MensaPagePageState();
}

class _MensaPagePageState extends State<MensaPage>
    with TickerProviderStateMixin {
  static final StudiPassauRepo _repo = StudiPassauRepo();
  final MensaBloc _mensaBloc = MensaBloc();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  DateTime selected = DateTimeTimetable.today();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(
      (_) => _refreshIndicatorKey.currentState?.show(),
    );
    _mensaBloc.stream.listen((event) {
      setState(() {});
    });
    refresh();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).mensaPlanTitle),
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
        drawer: StudiPassauDrawer(DrawerItem.mensaPlan),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: refresh,
          child: CustomScrollView(
            slivers: slivers(context),
          ),
        ),
      );

  List<Widget> slivers(BuildContext ctx) =>
      _repo.mensaPlan
          ?.map(
            (dm) => SliverStickyHeader(
              header: Container(
                height: 60,
                color: Colors.lightBlue,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Text(
                  '${weekday(dm.day.date)}, '
                  '${dateFormat(locale(ctx)).format(dm.day.date)}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed(
                  dm.meals
                      .map(
                        (m) => ListTile(
                          leading: CircleAvatar(
                            child: Text(m.category.characters.first),
                          ),
                          title: Text(
                            m.name,
                          ),
                          onTap: () => onTap(m),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ),
          )
          .toList(growable: false) ??
      [];

  void onTap(Meal m) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(m.name),
        content: Text(
          'Kategorie: ${m.category}\n'
          'Studenten: ${m.studentPrice}€\n'
          'Beschäftigte: ${m.employeePrice}€\n'
          'Gäste: ${m.othersPrice}€\n'
          'Schüler: ${m.pupilPrice}€\n'
          'Zusätze: ${m.notes}',
        ),
      ),
    );
  }

  Future<void> refresh() async {
    _mensaBloc.add(FetchMensaPlan());
    await _mensaBloc.stream.firstWhere((state) => state.finished);
  }
}
