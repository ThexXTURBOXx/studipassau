import 'package:studip/studip.dart';

class OAuthRepo {
  static OAuthRepo _singleton;
  StudIPClient apiClient;
  dynamic userData;

  factory OAuthRepo() {
    _singleton ??= OAuthRepo._internal();
    return _singleton;
  }

  OAuthRepo._internal();
}
