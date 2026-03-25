// ignore_for_file: avoid_classes_with_only_static_members

import 'package:envied/envied.dart';
import 'package:studipassau/constants.dart';

part 'env.g.dart';

@Envied(path: envFile, requireEnvFile: true)
abstract class Env {
  @EnviedField(varName: 'CLIENT_ID')
  static const String clientId = _Env.clientId;
  @EnviedField(varName: 'CLIENT_SECRET', defaultValue: '0')
  static const String clientSecret = _Env.clientSecret;
  @EnviedField(
    varName: 'SENTRY_DSN',
    defaultValue: 'https://0@o0.ingest.sentry.io/0',
  )
  static const String sentryDsn = _Env.sentryDsn;
}
