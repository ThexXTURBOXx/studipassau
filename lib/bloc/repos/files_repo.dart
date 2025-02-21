import 'dart:io' as io;

import 'package:http/http.dart';
import 'package:studipassau/bloc/providers/studip_provider.dart';
import 'package:studipassau/pages/files/widgets/course.dart';
import 'package:studipassau/pages/files/widgets/file.dart';
import 'package:studipassau/pages/files/widgets/folder.dart';
import 'package:supercharged/supercharged.dart';
import 'package:tuple/tuple.dart';

class FilesRepo {
  final _studIPProvider = StudIPDataProvider();

  Future<List<Course>> getCourses(String userId) async {
    final jsonCourses =
        (await _studIPProvider.apiGetJson(
              'users/$userId/courses?page[limit]=10000',
            ))['data']
            as List<dynamic>;
    return jsonCourses.map(Course.fromJson).toList(growable: false);
  }

  Future<Tuple2<List<Folder>, List<File>>> loadCourseTopFolder(
    String courseId,
  ) async {
    final json = await _studIPProvider.apiGetJson(
      'courses/$courseId/folders?page[limit]=10000',
    );
    final folders = json['data'] as List<dynamic>;
    final rootFolder =
        folders
            .filter(
              (f) =>
                  f['attributes'] != null &&
                  f['attributes']['folder-type'] == 'RootFolder',
            )
            .map(Folder.fromJson)
            .firstOrNull;
    return rootFolder == null ? Tuple2([], []) : loadFolder(rootFolder.id);
  }

  Future<Tuple2<List<Folder>, List<File>>> loadFolder(String folderId) async =>
      parseFolder(
        await _studIPProvider.apiGetJson(
          'folders/$folderId/folders?page[limit]=10000',
        ),
        await _studIPProvider.apiGetJson(
          'folders/$folderId/file-refs?page[limit]=10000',
        ),
      );

  Future<Tuple2<List<Folder>, List<File>>> parseFolder(
    jsonFolders,
    jsonFiles,
  ) async => Tuple2(
    (jsonFolders['data'] as List<dynamic>)
        .filter(
          (f) => f['attributes'] != null && f['attributes']['name'] != null,
        )
        .map(Folder.fromJson)
        .toList(growable: false),
    (jsonFiles['data'] as List<dynamic>)
        .filter(
          (f) => f['attributes'] != null && f['attributes']['name'] != null,
        )
        .map(File.fromJson)
        .toList(growable: false),
  );

  Future<String> downloadFile(
    io.File toFile,
    Request request, {
    ProgressListener? onProgress,
    Function? onError,
    void Function(String)? onDone,
  }) => _studIPProvider.downloadFile(
    toFile,
    request,
    onProgress: onProgress,
    onError: onError,
    onDone: onDone,
  );
}
