import 'dart:collection';
import 'dart:io' as io;

import 'package:catcher_2/catcher_2.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/providers/studip_provider.dart';
import 'package:studipassau/bloc/repos/courses_repo.dart';
import 'package:studipassau/bloc/repos/files_repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/pages/files/widgets/course.dart';
import 'package:studipassau/pages/files/widgets/file.dart';
import 'package:studipassau/pages/files/widgets/folder.dart';
import 'package:studipassau/util/sort.dart';

class FilesCubit extends Cubit<FilesState> {
  FilesCubit(this._filesRepo, this._coursesRepo)
    : super(
        FilesState(
          StudiPassauState.notFetched,
          currentFolders: Queue<Folder>(),
        ),
      );

  final FilesRepo _filesRepo;

  final CoursesRepo _coursesRepo;

  Future<void> loadCourses(String userId) async {
    emit(state.copyWith(state: StudiPassauState.fetching));

    try {
      final courses = (await _coursesRepo.getCourses(userId)).sorted(
        compareBy<Course, String>(
          (c) => c.attributes.title,
        ).thenByNullable((c) => c.attributes.courseNumber),
      );

      emit(state.copyWith(state: StudiPassauState.fetched, courses: courses));
    } on SessionInvalidException {
      emit(state.copyWith(state: StudiPassauState.authenticationError));
    } on io.SocketException {
      emit(state.copyWith(state: StudiPassauState.httpError));
    } catch (e, s) {
      Catcher2.reportCheckedError(e, s);
      emit(state.copyWith(state: StudiPassauState.fetchError));
    }
  }

  Future<void> loadCourseTopFolder(Course course) async {
    emit(state.copyWith(state: StudiPassauState.fetching));

    try {
      final topFolder = await _filesRepo.loadCourseTopFolder(course.id);

      final folders = topFolder.item1.sorted(
        compareBy<Folder, String>(
          (f) => f.attributes.name,
        ).thenBy((f) => f.attributes.changeDate),
      );

      final files = topFolder.item2.sorted(
        compareBy<FileRef, String>(
          (f) => f.attributes.name,
        ).thenBy((f) => f.attributes.changeDate),
      );

      emit(
        state.copyWith(
          state: StudiPassauState.fetched,
          currentCourse: course,
          folders: folders,
          files: files,
        ),
      );
    } on SessionInvalidException {
      emit(state.copyWith(state: StudiPassauState.authenticationError));
    } on io.SocketException {
      emit(state.copyWith(state: StudiPassauState.httpError));
    } catch (e, s) {
      Catcher2.reportCheckedError(e, s);
      emit(state.copyWith(state: StudiPassauState.fetchError));
    }
  }

  Future<void> loadFolder(Folder folder, {bool refresh = false}) async {
    emit(state.copyWith(state: StudiPassauState.fetching));

    try {
      final topFolder = await _filesRepo.loadFolder(folder.id);

      final folders = topFolder.item1.sorted(
        compareBy<Folder, String>(
          (f) => f.attributes.name,
        ).thenBy((f) => f.attributes.changeDate),
      );

      final files = topFolder.item2.sorted(
        compareBy<FileRef, String>(
          (f) => f.attributes.name,
        ).thenBy((f) => f.attributes.changeDate),
      );

      emit(
        state.copyWith(
          state: StudiPassauState.fetched,
          currentFolders: refresh
              ? state.currentFolders
              : (state.currentFolders..addFirst(folder)),
          folders: folders,
          files: files,
        ),
      );
    } on SessionInvalidException {
      emit(state.copyWith(state: StudiPassauState.authenticationError));
    } on io.SocketException {
      emit(state.copyWith(state: StudiPassauState.httpError));
    } catch (e, s) {
      Catcher2.reportCheckedError(e, s);
      emit(state.copyWith(state: StudiPassauState.fetchError));
    }
  }

  Future<void> refresh({String? userId, Course? course, Folder? folder}) async {
    if (folder != null) {
      return loadFolder(folder, refresh: true);
    } else if (course != null) {
      return loadCourseTopFolder(course);
    } else if (userId != null) {
      return loadCourses(userId);
    }
  }

  Future<String> downloadFile(
    FileRef file, {
    ProgressListener? onProgress,
    Function? onError,
    void Function(String)? onDone,
  }) async {
    final dirs =
        (await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        )) ??
        [
          await getExternalStorageDirectory() ??
              await getApplicationDocumentsDirectory(),
        ];
    final toFile = io.File('${dirs[0].path}/${file.attributes.name}');

    return _filesRepo.downloadFile(
      toFile,
      Request('GET', Uri.parse('${apiBaseUrl}file-refs/${file.id}/content')),
      onProgress: onProgress,
      onError: onError,
      onDone: onDone,
    );
  }
}
