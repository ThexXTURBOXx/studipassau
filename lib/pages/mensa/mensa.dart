import 'package:collection/collection.dart';
import 'package:dart_date/dart_date.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:openmensa/openmensa.dart';
import 'package:studipassau/bloc/cubits/mensa_cubit.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/drawer/drawer.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/settings/settings.dart';
import 'package:supercharged/supercharged.dart';

const routeMensa = '/mensa';

class MensaPage extends StatefulWidget {
  const MensaPage({super.key});

  @override
  State<StatefulWidget> createState() => _MensaPagePageState();
}

class _MensaPagePageState extends State<MensaPage>
    with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool isWideScreen = false;

  bool onlineSync = getPref(mensaAutoSyncPref);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await _refreshIndicatorKey.currentState?.show(),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<bool>('isWideScreen', isWideScreen))
      ..add(DiagnosticsProperty<bool>('onlineSync', onlineSync));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(S.of(context).mensaPlanTitle),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: S.of(context).refresh,
          onPressed: () async =>
              await _refreshIndicatorKey.currentState?.show(),
        ),
      ],
    ),
    drawer: const StudiPassauDrawer(DrawerItem.mensaPlan),
    body: BlocConsumer<MensaCubit, MensaState>(
      listener: (context, state) {
        if (state.state == StudiPassauState.fetchError) {
          showSnackBar(context, S.of(context).mensaError);
        } else {
          showErrorMessage(context, state);
        }
      },
      builder: (context, state) {
        isWideScreen = MediaQuery.of(context).size.width > wideScreenWidth;
        return RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () async => refresh(context),
          child: CustomScrollView(slivers: slivers(state.menu)),
        );
      },
    ),
  );

  List<Widget> slivers(List<DayMenu> menu) {
    final today = DateTime.now().startOfDay;
    return menu
        .filter((e) => e.day.date.startOfDay >= today)
        .sortedBy((e) => e.day.date)
        .map(
          (dm) => SliverStickyHeader(
            header: Container(
              height: 60,
              color: Colors.lightBlue,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Text(
                '${formatWeekday(dm.day.date)}, '
                '${formatDate(dm.day.date)}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed(
                dm.meals
                    .map(
                      (m) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: getFoodColor(
                            m.category.trim().characters.first,
                          ),
                          child: Text(m.category.trim().characters.first),
                        ),
                        trailing: isWideScreen
                            ? Text(
                                getQuickPrice(m),
                                style: const TextStyle(color: Colors.grey),
                              )
                            : null,
                        title: Text(m.name.trim()),
                        onTap: () async => onTap(m),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
        )
        .toList(growable: false);
  }

  String getQuickPrice(Meal m) {
    switch (getPref(mensaTypePref)) {
      case mensaTypePrefStudent:
        return formatEuroPrice(m.studentPrice ?? 0);
      case mensaTypePrefEmployee:
        return formatEuroPrice(m.employeePrice ?? 0);
      case mensaTypePrefGuest:
        return formatEuroPrice(m.othersPrice ?? 0);
      case mensaTypePrefPupil:
        return formatEuroPrice(m.pupilPrice ?? 0);
      default:
        return '';
    }
  }

  Future<void> onTap(Meal m) async {
    final s = S.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(m.name.trim()),
        content: Text(
          '${s.category}: ${m.category.trim()}\n'
          '${formatPrice(s.students, m.studentPrice)}'
          '${formatPrice(s.employees, m.employeePrice)}'
          '${formatPrice(s.guests, m.othersPrice)}'
          '${formatPrice(s.pupils, m.pupilPrice)}'
          '${formatAdditives(s, m.notes)}',
        ),
      ),
    );
  }

  String formatPrice(String category, double? price) =>
      price != null ? '$category: ${formatEuroPrice(price)}\n' : '';

  String formatAdditives(S s, List<String>? additives) =>
      additives != null && additives.isNotEmpty
      ? '${s.additives}: ${additives.join(", ")}'
      : '${s.additives}: ${s.noAdditives}';

  Color? getFoodColor(String category) {
    switch (category) {
      case 's':
      case 'S':
        return Color(getPref(soupColorPref));
      case 'h':
      case 'H':
        return Color(getPref(mainDishColorPref));
      case 'b':
      case 'B':
        return Color(getPref(garnishColorPref));
      case 'n':
      case 'N':
        return Color(getPref(dessertColorPref));
      default:
        return null;
    }
  }

  Future<void> refresh(BuildContext context) async {
    await context.read<MensaCubit>().fetchMensaPlan(onlineSync: onlineSync);
    onlineSync = true;
  }
}
