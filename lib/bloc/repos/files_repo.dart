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
    final jsonCourses = (await _studIPProvider
            .apiGetJson('user/$userId/courses?limit=10000'))['collection']
        as Map<String, dynamic>;
    return jsonCourses.values.map(Course.fromJson).toList(growable: false);
  }

  Future<Tuple2<List<Folder>, List<File>>> loadCourseTopFolder(
    String courseId,
  ) async =>
      parseFolder(
        await _studIPProvider.apiGetJson('course/$courseId/top_folder'),
      );

  Future<Tuple2<List<Folder>, List<File>>> loadFolder(String folderId) async =>
      parseFolder(await _studIPProvider.apiGetJson('folder/$folderId'));

  Future<Tuple2<List<Folder>, List<File>>> parseFolder(json) async {
    final jsonFolders = json['subfolders'] as List<dynamic>;
    final jsonFiles = json['file_refs'] as List<dynamic>;
    return Tuple2(
      jsonFolders
          .filter((f) => f['name'] != null)
          .map(Folder.fromJson)
          .toList(growable: false),
      jsonFiles
          .filter((f) => f['name'] != null)
          .map(File.fromJson)
          .toList(growable: false),
    );
  }

  Future<String> downloadFile(
    io.File toFile,
    Request request, {
    ProgressListener? onProgress,
    Function? onError,
    void Function(String)? onDone,
  }) =>
      _studIPProvider.downloadFile(
        toFile,
        request,
        onProgress: onProgress,
        onError: onError,
        onDone: onDone,
      );
}
