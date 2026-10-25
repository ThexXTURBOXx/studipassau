import 'package:shared_preferences/shared_preferences.dart';

class SharedStorageDataProvider {
  static late final SharedPreferencesWithCache sharedPrefs;

  String? getString(String key) => sharedPrefs.getString(key);

  List<String>? getStringList(String key) => sharedPrefs.getStringList(key);

  Future<void> writeString(String key, String value) =>
      sharedPrefs.setString(key, value);

  Future<void> writeStringList(String key, List<String> value) =>
      sharedPrefs.setStringList(key, value);
}
