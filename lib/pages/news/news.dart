import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studipassau/bloc/cubits/news_cubit.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/drawer/drawer.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/news/widgets/news_item.dart';
import 'package:studipassau/pages/settings/settings.dart';

const routeNews = '/news';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<StatefulWidget> createState() => _NewsPagePageState();
}

class _NewsPagePageState extends State<NewsPage> with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool onlineSync = getPref(newsAutoSyncPref);

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
    properties.add(DiagnosticsProperty<bool>('onlineSync', onlineSync));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(S.of(context).newsTitle),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: S.of(context).refresh,
          onPressed:
              () async => await _refreshIndicatorKey.currentState?.show(),
        ),
      ],
    ),
    drawer: const StudiPassauDrawer(DrawerItem.news),
    body: BlocConsumer<NewsCubit, NewsState>(
      listener: showErrorMessage,
      builder:
          (context, state) => RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () async => refresh(context),
            child: ListView(
              children: state.newsOrEmpty
                  .map((e) => NewsWidget(news: e))
                  .toList(growable: false),
            ),
          ),
    ),
  );

  Future<void> refresh(BuildContext context) async {
    await context.read<NewsCubit>().fetchNews(onlineSync: onlineSync);
    onlineSync = true;
  }
}
