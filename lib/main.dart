import 'dart:async';

import 'package:catcher_2/catcher_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studipassau/bloc/bloc_provider.dart';
import 'package:studipassau/bloc/providers/shared_storage_provider.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/env/env.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/files/files.dart';
import 'package:studipassau/pages/login/login.dart';
import 'package:studipassau/pages/mensa/mensa.dart';
import 'package:studipassau/pages/news/news.dart';
import 'package:studipassau/pages/roomfinder/roomfinder.dart';
import 'package:studipassau/pages/schedule/schedule.dart';
import 'package:studipassau/pages/settings/settings.dart';
import 'package:timetable/timetable.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Intl.defaultLocale = await findSystemLocale();

  packageInfo = await PackageInfo.fromPlatform();

  await installRootCertificates();

  final debugOptions = Catcher2Options.getDefaultDebugOptions();
  final releaseOptions = Catcher2Options(
    DialogReportMode(),
    [
      SentryHandler(SentryClient(SentryFlutterOptions()..dsn = Env.sentryDsn)),
      ConsoleHandler(),
    ],
    localizationOptions: [
      LocalizationOptions.buildDefaultEnglishOptions(),
      LocalizationOptions.buildDefaultGermanOptions(),
    ],
  );

  SharedStorageDataProvider.sharedPrefs = await SharedPreferences.getInstance();

  // TODO(Nico): Yes, this is not optimal. We should fix the underlying issue
  //             at some point, i.e. remove the global reference...
  prefService = await PrefServiceShared.init(defaults: defaults);
  targetRoute = getPref(startRoutePref);

  const quickActions = QuickActions();
  await quickActions.initialize((shortcutType) => targetRoute = shortcutType);
  await quickActions.setShortcutItems(<ShortcutItem>[
    const ShortcutItem(
      type: routeSchedule,
      // TODO(Nico): Localize!
      localizedTitle: 'Stundenplan',
      // TODO(Nico): icon: 'IconResource',
    ),
    const ShortcutItem(
      type: routeMensa,
      // TODO(Nico): Localize!
      localizedTitle: 'Mensaplan',
      // TODO(Nico): icon: 'IconResource',
    ),
    const ShortcutItem(
      type: routeFiles,
      // TODO(Nico): Localize!
      localizedTitle: 'Dateien',
      // TODO(Nico): icon: 'IconResource',
    ),
    const ShortcutItem(
      type: routeRoomFinder,
      // TODO(Nico): Localize!
      localizedTitle: 'Raumfinder',
      // TODO(Nico): icon: 'IconResource',
    ),
    const ShortcutItem(
      type: routeNews,
      // TODO(Nico): Localize!
      localizedTitle: 'Neuigkeiten',
      // TODO(Nico): icon: 'IconResource',
    ),
  ]);

  Catcher2(
    rootWidget: PrefService(
      service: prefService,
      child: const StudiPassauApp(),
    ),
    debugConfig: debugOptions,
    releaseConfig: releaseOptions,
  );
}

class StudiPassauApp extends StatefulWidget {
  const StudiPassauApp({super.key});

  @override
  State<StatefulWidget> createState() => _StudiPassauAppState();
}

class _StudiPassauAppState extends State<StudiPassauApp> {
  @override
  void initState() {
    super.initState();
    prefService
      ..addKeyListener(uiThemePref, () {
        setState(() {});
      })
      ..addKeyListener(material3Pref, () {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final bool m3 = getPref(material3Pref);
    return StudiPassauBlocProvider(
      child: MaterialApp(
        onGenerateTitle: (context) => S.of(context).applicationTitle,
        debugShowCheckedModeBanner: false,
        themeMode: getThemeMode(),
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: m3 ? null : Colors.blue,
          colorSchemeSeed: m3 ? Colors.blue : null,
          useMaterial3: m3,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: m3 ? null : Colors.blue,
          colorSchemeSeed: m3 ? Colors.blue : null,
          useMaterial3: getPref(material3Pref),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        navigatorKey: Catcher2.navigatorKey,
        localizationsDelegates: const [
          S.delegate,
          TimetableLocalizationsDelegate(
            setIntlLocale: false,
            fallbackLocale: Locale('en', 'US'),
          ),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        initialRoute: routeLogin,
        routes: {
          routeLogin: (ctx) => const LoginPage(),
          routeSchedule: (ctx) => const SchedulePage(),
          routeMensa: (ctx) => const MensaPage(),
          routeFiles: (ctx) => const FilesPage(),
          routeRoomFinder: (ctx) => const RoomFinderPage(),
          routeNews: (ctx) => const NewsPage(),
          routeSettings: (ctx) => const SettingsPage(),
        },
      ),
    );
  }

  ThemeMode getThemeMode() {
    switch (getPref(uiThemePref)) {
      case uiThemePrefLight:
        return ThemeMode.light;
      case uiThemePrefDark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
