import 'package:studip/studip.dart';

class StudIPDataProvider {
  static late StudIPClient _apiClient;

  // This should not have a getter... However, a setter alone is pretty evil?!
  // ignore: avoid_setters_without_getters
  static set apiClient(StudIPClient newClient) => _apiClient = newClient;

  Future<dynamic> apiGetJson(
    String endpoint, {
    Map<String, String>? headers,
  }) =>
      _apiClient.apiGetJson(endpoint, headers: headers);
}
