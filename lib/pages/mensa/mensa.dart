import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:openmensa/openmensa.dart';
import 'package:sprintf/sprintf.dart';
import 'package:studipassau/bloc/cubits/mensa_cubit.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/drawer/drawer.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/settings/settings.dart';

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

  @override
  void initState() {
    super.initState();
    if (getPref(mensaAutoSyncPref)) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _refreshIndicatorKey.currentState?.show(),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).mensaPlanTitle),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: S.of(context).refresh,
              onPressed: () => _refreshIndicatorKey.currentState?.show(),
            ),
          ],
        ),
        drawer: const StudiPassauDrawer(DrawerItem.mensaPlan),
        body: BlocConsumer<MensaCubit, MensaState>(
          listener: (context, state) {
            if (state.errored) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).httpError)),
              );
            }
          },
          builder: (context, state) => RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () => refresh(context),
            child: CustomScrollView(slivers: slivers(state.menu)),
          ),
        ),
      );

  List<Widget> slivers(List<DayMenu> menu) => menu
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
                        backgroundColor:
                            getFoodColor(m.category.characters.first),
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
      .toList(growable: false);

  void onTap(Meal m) {
    final s = S.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(m.name),
        content: Text(
          '${s.category}: ${m.category}\n'
          '${formatPrice(s.students, s.priceFormat, m.studentPrice)}'
          '${formatPrice(s.employees, s.priceFormat, m.employeePrice)}'
          '${formatPrice(s.guests, s.priceFormat, m.othersPrice)}'
          '${formatPrice(s.pupils, s.priceFormat, m.pupilPrice)}'
          '${formatAdditives(s, m.notes)}',
        ),
      ),
    );
  }

  String formatPrice(String category, String format, double? price) =>
      price != null
          ? '$category: ${sprintf(format, [formatDecimal(price)])}\n'
          : '';

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
    await context.read<MensaCubit>().fetchMensaPlan();
  }
}
