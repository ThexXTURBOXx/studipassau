import 'dart:async';

import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/login/login.dart';
import 'package:studipassau/pages/schedule/schedule.dart';
import 'package:timetable/timetable.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  setLocalLocation(location);

  await dotenv.load(fileName: ENV_FILE);

  final debugOptions = CatcherOptions.getDefaultDebugOptions();
  final releaseOptions = CatcherOptions(DialogReportMode(),
      [SentryHandler(SentryClient(SentryFlutterOptions()..dsn = sentryDsn))]);

  Catcher(
    rootWidget: StudiPassauApp(),
    debugConfig: debugOptions,
    releaseConfig: releaseOptions,
  );
}

class StudiPassauApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => S.of(context).applicationTitle,
      debugShowCheckedModeBanner: false,
      //themeMode: themeSettings.currentTheme,
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
      //locale: localeSettings.currentLocale,
      localizationsDelegates: const [
        S.delegate,
        TimetableLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      initialRoute: ROUTE_LOGIN,
      routes: {
        ROUTE_LOGIN: (ctx) => LoginPage(),
        ROUTE_SCHEDULE: (ctx) => SchedulePage(),
      },
    );
  }
}
