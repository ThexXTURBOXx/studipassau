import 'dart:async';

import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pref/pref.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studipassau/bloc/cubits/login_cubit.dart';
import 'package:studipassau/bloc/cubits/mensa_cubit.dart';
import 'package:studipassau/bloc/cubits/schedule_cubit.dart';
import 'package:studipassau/bloc/providers/shared_storage_provider.dart';
import 'package:studipassau/bloc/repos/mensa_repo.dart';
import 'package:studipassau/bloc/repos/storage_repo.dart';
import 'package:studipassau/bloc/repos/studip_repo.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';
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
    )
  ]);

  SharedStorageDataProvider.sharedPrefs = await SharedPreferences.getInstance();

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
  const StudiPassauApp({super.key});

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
    prefService.addKeyListener(material3Pref, () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider<StorageRepo>(
            create: (context) => StorageRepo(),
          ),
          RepositoryProvider<StudIPRepo>(
            create: (context) => StudIPRepo(),
          ),
          RepositoryProvider<MensaRepo>(
            create: (context) => MensaRepo(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<LoginCubit>(
              create: (context) => LoginCubit(context.read<StorageRepo>()),
            ),
            BlocProvider<ScheduleCubit>(
              create: (context) => ScheduleCubit(
                context.read<StorageRepo>(),
                context.read<StudIPRepo>(),
              ),
            ),
            BlocProvider<MensaCubit>(
              create: (context) => MensaCubit(
                context.read<StorageRepo>(),
                context.read<MensaRepo>(),
              ),
            ),
          ],
          child: MaterialApp(
            onGenerateTitle: (context) => S.of(context).applicationTitle,
            debugShowCheckedModeBanner: false,
            themeMode: getThemeMode(),
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
              useMaterial3: getPref(material3Pref),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
              useMaterial3: getPref(material3Pref),
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
              routeSettings: (ctx) => const SettingsPage(),
            },
          ),
        ),
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
