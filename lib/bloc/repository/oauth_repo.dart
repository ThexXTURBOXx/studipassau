import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studip/studip.dart';

class OAuthRepo {
  static OAuthRepo _singleton;
  final _storage = const FlutterSecureStorage();
  StudIPClient apiClient;
  dynamic userData;

  factory OAuthRepo() {
    _singleton ??= OAuthRepo._internal();
    return _singleton;
  }

  FlutterSecureStorage get storage => _storage;

  OAuthRepo._internal();
}
