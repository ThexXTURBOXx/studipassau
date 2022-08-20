import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', requireEnvFile: true, obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'CONSUMER_KEY')
  static final String consumerKey = _Env.consumerKey;
  @EnviedField(varName: 'CONSUMER_SECRET')
  static final String consumerSecret = _Env.consumerSecret;
  @EnviedField(varName: 'SENTRY_DSN')
  static final String sentryDsn = _Env.sentryDsn;
}
