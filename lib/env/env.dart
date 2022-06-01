import 'package:envify/envify.dart';

part 'env.g.dart';

@Envify(path: '.env')
abstract class Env {
  static const consumerKey = _Env.consumerKey;

  static const consumerSecret = _Env.consumerSecret;

  static const sentryDsn = _Env.sentryDsn;
}
