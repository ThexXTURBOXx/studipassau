import 'package:shared_preferences/shared_preferences.dart';

class SharedStorageDataProvider {
  static late final SharedPreferences sharedPrefs;

  String? getString(String key) => sharedPrefs.getString(key);

  List<String>? getStringList(String key) => sharedPrefs.getStringList(key);

  Future<bool> writeString(String key, String value) =>
      sharedPrefs.setString(key, value);

  Future<bool> writeStringList(String key, List<String> value) =>
      sharedPrefs.setStringList(key, value);
}
