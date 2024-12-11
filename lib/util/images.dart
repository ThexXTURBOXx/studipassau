import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:studip/studip.dart';

class StudIPCacheManager extends CacheManager {
  StudIPCacheManager._()
      : super(Config(key, fileService: StudIPHttpFileService()));

  static const key = 'StudIPCache';

  static final StudIPCacheManager instance = StudIPCacheManager._();
}

class StudIPHttpFileService extends HttpFileService {
  static late StudIPClient _apiClient;

  // This should not have a getter... However, a setter alone is pretty evil?!
  // ignore: avoid_setters_without_getters
  static set apiClient(StudIPClient newClient) => _apiClient = newClient;

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final req = http.Request('GET', Uri.parse(url));
    if (headers != null) {
      req.headers.addAll(headers);
    }
    return HttpGetResponse(await _apiClient.send(req));
  }
}
