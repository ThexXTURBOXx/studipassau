import 'package:envify/envify.dart';

part 'env.g.dart';

@Envify(path: '.env', obfuscate: true)
abstract class Env {
  static final String consumerKey = _Env.consumerKey;

  static final String consumerSecret = _Env.consumerSecret;

  static final String sentryDsn = _Env.sentryDsn;
}
