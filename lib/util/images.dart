import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:studipassau/bloc/repo.dart';

class StudIPCacheManager extends CacheManager {
  static const key = 'StudIPCache';

  static final StudIPCacheManager _singleton = StudIPCacheManager._internal();

  factory StudIPCacheManager() => _singleton;

  StudIPCacheManager._internal()
      : super(Config(key, fileService: StudIPHttpFileService()));
}

class StudIPHttpFileService extends HttpFileService {
  StudiPassauRepo repo = StudiPassauRepo();

  @override
  Future<FileServiceResponse> get(String url,
      {Map<String, String>? headers}) async {
    final req = http.Request('GET', Uri.parse(url));
    if (headers != null) {
      req.headers.addAll(headers);
    }
    return HttpGetResponse(await repo.apiClient.send(req));
  }
}
