import 'package:studipassau/bloc/providers/secure_storage_provider.dart';
import 'package:studipassau/bloc/providers/shared_storage_provider.dart';

const userDataKey = 'user_dataV2';
const scheduleKey = 'scheduleV2';
const mensaPlanKey = 'mensa_planV2';
const newsKey = 'newsV2';

class StorageRepo {
  final _sharedStorageProvider = SharedStorageDataProvider();

  final _secureStorageProvider = SecureStorageDataProvider();

  String? getString(String key) => _sharedStorageProvider.getString(key);

  List<String>? getStringList(String key) =>
      _sharedStorageProvider.getStringList(key);

  Future<bool> writeString({required String key, required String value}) =>
      _sharedStorageProvider.writeString(key, value);

  Future<bool> writeStringList({
    required String key,
    required List<String> value,
  }) => _sharedStorageProvider.writeStringList(key, value);

  Future<Map<String, String>> readAllSecure() =>
      _secureStorageProvider.readAll();

  Future<void> writeSecure({required String key, required String? value}) =>
      _secureStorageProvider.write(key: key, value: value);
}
