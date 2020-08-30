import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BaseRepo {
  final _storage = const FlutterSecureStorage();

  FlutterSecureStorage get storage => _storage;
}
