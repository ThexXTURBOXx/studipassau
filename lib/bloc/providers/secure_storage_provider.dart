import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageDataProvider {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> readAll() => _storage.readAll();

  Future<void> write({required String key, required String? value}) =>
      _storage.write(key: key, value: value);
}
