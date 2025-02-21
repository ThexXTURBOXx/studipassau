import 'dart:io';

import 'package:http/http.dart';
import 'package:studip/studip.dart';

typedef ProgressListener = void Function(double);

class StudIPDataProvider {
  static late StudIPClient _apiClient;

  // This should not have a getter... However, a setter alone is pretty evil?!
  // ignore: avoid_setters_without_getters
  static set apiClient(StudIPClient newClient) => _apiClient = newClient;

  Future<dynamic> apiGetJson(String endpoint, {Map<String, String>? headers}) =>
      _apiClient.apiGetJson(endpoint, headers: headers);

  Future<String> downloadFile(
    File toFile,
    Request request, {
    ProgressListener? onProgress,
    Function? onError,
    void Function(String)? onDone,
  }) async {
    final output = toFile.openWrite();
    var downloaded = 0;
    final resp = _apiClient.send(request);
    resp.asStream().listen((r) {
      r.stream.listen(
        (chunk) {
          if (r.contentLength != null) {
            onProgress?.call((downloaded * 100) / r.contentLength!);
          }
          output.add(chunk);
          downloaded += chunk.length;
        },
        onError: onError,
        onDone: () async {
          onProgress?.call(100);
          await output.close();
          onDone?.call(toFile.path);
        },
      );
    });
    return toFile.path;
  }
}
