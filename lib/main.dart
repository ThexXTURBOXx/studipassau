import 'dart:async';

import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/about/about.dart';
import 'package:studipassau/pages/login/login.dart';
import 'package:studipassau/pages/mensa/mensa.dart';
import 'package:studipassau/pages/schedule/schedule.dart';
import 'package:studipassau/pages/settings/settings.dart';
import 'package:timetable/timetable.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  setLocalLocation(location);

  await dotenv.load(fileName: envFile);

  packageInfo = await PackageInfo.fromPlatform();

  final debugOptions = CatcherOptions.getDefaultDebugOptions();
  final releaseOptions = CatcherOptions(DialogReportMode(), [
    SentryHandler(
      SentryClient(SentryFlutterOptions()..dsn = sentryDsn),
    ),
    ConsoleHandler(),
  ]);

  // TODO(Nico): Yes, this is not optimal. We should fix the underlying issue
  //             at some point, i.e. remove the global reference...
  prefService = await PrefServiceShared.init(defaults: defaults);

  Catcher(
    rootWidget: PrefService(
      service: prefService,
      child: const StudiPassauApp(),
    ),
    debugConfig: debugOptions,
    releaseConfig: releaseOptions,
  );
}

class StudiPassauApp extends StatefulWidget {
  const StudiPassauApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StudiPassauAppState();
}

class _StudiPassauAppState extends State<StudiPassauApp> {
  @override
  void initState() {
    super.initState();
    prefService.addKeyListener(uiThemePref, () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        onGenerateTitle: (context) => S.of(context).applicationTitle,
        debugShowCheckedModeBanner: false,
        themeMode: getThemeMode(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        navigatorKey: Catcher.navigatorKey,
        localizationsDelegates: const [
          S.delegate,
          TimetableLocalizationsDelegate(),
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
          routeAbout: (ctx) => const AboutPage(),
          routeSettings: (ctx) => const SettingsPage(),
        },
      );

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
