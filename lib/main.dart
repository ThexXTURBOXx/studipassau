import 'dart:async';

import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/login/login.dart';
import 'package:studipassau/pages/schedule/schedule.dart';
import 'package:timetable/timetable.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final debugOptions = CatcherOptions.getDefaultDebugOptions();
  final releaseOptions = CatcherOptions(DialogReportMode(), [
    SentryHandler(
        SentryClient(SentryFlutterOptions()..dsn = dotenv.env['SENTRY_DSN']))
  ]);

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
      initialRoute: '/login',
      routes: {
        '/login': (ctx) => LoginPage(),
        '/schedule': (ctx) => SchedulePage(),
      },
    );
  }
}
