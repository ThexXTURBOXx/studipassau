import 'dart:io' as io;

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:studipassau/bloc/providers/studip_provider.dart';
import 'package:studipassau/models/file_ref.dart';
import 'package:studipassau/models/folder.dart';
import 'package:studipassau/models/jsonapi.dart';
import 'package:tuple/tuple.dart';

class FilesRepo {
  final _studIPProvider = StudIPDataProvider();

  Future<Tuple2<List<Folder>, List<FileRef>>> loadCourseTopFolder(
    String courseId,
  ) async {
    final json = await _studIPProvider.apiGetJson(
      'courses/$courseId/folders?page[limit]=10000',
    );
    if (json?['data'] is! Iterable) return Tuple2([], []);

    final folders = parseCollection<FolderAttributes>(
      json,
      (item) => FolderAttributes.fromJson(item as Map<String, dynamic>),
    );
    final rootFolder = folders.firstWhereOrNull(
      (f) => f.attributes.folderType == 'RootFolder',
    );
    return rootFolder == null ? Tuple2([], []) : loadFolder(rootFolder.id);
  }

  Future<Tuple2<List<Folder>, List<FileRef>>> loadFolder(
    String folderId,
  ) async {
    final results = await Future.wait([
      _studIPProvider.apiGetJson('folders/$folderId/folders?page[limit]=10000'),
      _studIPProvider.apiGetJson(
        'folders/$folderId/file-refs?page[limit]=10000',
      ),
    ]);

    return parseFolder(results[0], results[1]);
  }

  Future<Tuple2<List<Folder>, List<FileRef>>> parseFolder(
    dynamic jsonFolders,
    dynamic jsonFiles,
  ) async {
    final folders = jsonFolders['data'] is Iterable
        ? parseCollection<FolderAttributes>(
            jsonFolders,
            (item) => FolderAttributes.fromJson(item as Map<String, dynamic>),
          )
        : <Folder>[];

    final files = jsonFiles['data'] is Iterable
        ? parseCollection<FileRefAttributes>(
            jsonFiles,
            (item) => FileRefAttributes.fromJson(item as Map<String, dynamic>),
          )
        : <FileRef>[];

    return Tuple2(folders, files);
  }

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
