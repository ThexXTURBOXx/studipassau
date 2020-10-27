import 'dart:async';

import 'package:StudiPassau/pages/login/login.dart';
import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry/sentry.dart';
import 'package:time_machine/time_machine.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final flutterI18nDelegate = FlutterI18nDelegate(
      translationLoader: FileTranslationLoader(
    decodeStrategies: [JsonDecodeStrategy()],
    useCountryCode: false,
    fallbackFile: 'en',
    basePath: 'assets/locales',
  ));

  await DotEnv().load('.env');

  final debugOptions = CatcherOptions.getDefaultDebugOptions();
  final releaseOptions = CatcherOptions(DialogReportMode(),
      [SentryHandler(SentryClient(dsn: DotEnv().env['SENTRY_DSN']))]);

  WidgetsFlutterBinding.ensureInitialized();
  await TimeMachine.initialize({'rootBundle': rootBundle});

  Catcher(
    StudiPassauApp(flutterI18nDelegate),
    debugConfig: debugOptions,
    releaseConfig: releaseOptions,
  );
}

class StudiPassauApp extends StatelessWidget {
  final FlutterI18nDelegate flutterI18nDelegate;

  const StudiPassauApp(this.flutterI18nDelegate);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudiPassau',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorKey: Catcher.navigatorKey,
      localizationsDelegates: [
        flutterI18nDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: const [Locale('en'), Locale('de')],
      home: LoginPage(),
    );
  }
}
