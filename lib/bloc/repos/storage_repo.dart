import 'package:studipassau/bloc/providers/secure_storage_provider.dart';

const oAuthTokenKey = 'oauth_token';
const oAuthSecretKey = 'oauth_secret';

class StorageRepo {
  final _secureStorageProvider = SecureStorageDataProvider();

  Future<Map<String, String>> readAll() => _secureStorageProvider.readAll();

  Future<void> write({required String key, required String? value}) =>
      _secureStorageProvider.write(key: key, value: value);
}
