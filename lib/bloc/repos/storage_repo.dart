import 'package:studipassau/bloc/providers/secure_storage_provider.dart';
import 'package:studipassau/bloc/providers/shared_storage_provider.dart';

const userDataKey = 'user_dataV2';
const scheduleKey = 'scheduleV2';
const mensaPlanKey = 'mensa_planV2';
const newsKey = 'newsV2';
const coursesKey = 'coursesV2';
const extraCoursesKey = 'extraCoursesV2';
const courseMembershipsKey = 'courseMembershipsV2';
const semestersKey = 'semestersV2';

class StorageRepo {
  final _sharedStorageProvider = SharedStorageDataProvider();

  final _secureStorageProvider = SecureStorageDataProvider();

  Future<String?> getString(String key) async =>
      _sharedStorageProvider.getString(key);

  Future<List<String>?> getStringList(String key) async =>
      _sharedStorageProvider.getStringList(key);

  Future<void> writeString({
    required String key,
    required String value,
  }) async => _sharedStorageProvider.writeString(key, value);

  Future<void> writeStringList({
    required String key,
    required List<String> value,
  }) async => _sharedStorageProvider.writeStringList(key, value);

  Future<Map<String, String>> readAllSecure() =>
      _secureStorageProvider.readAll();

  Future<void> writeSecure({required String key, required String? value}) =>
      _secureStorageProvider.write(key: key, value: value);
}
