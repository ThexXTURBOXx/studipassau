import 'dart:collection';
import 'dart:io' as io;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/providers/studip_provider.dart';
import 'package:studipassau/bloc/repos/files_repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/pages/files/widgets/course.dart';
import 'package:studipassau/pages/files/widgets/file.dart';
import 'package:studipassau/pages/files/widgets/folder.dart';

class FilesCubit extends Cubit<FilesState> {
  final FilesRepo _filesRepo;

  FilesCubit(this._filesRepo)
      : super(
          FilesState(
            StudiPassauState.notFetched,
            currentFolders: Queue<Folder>(),
          ),
        );

  Future<void> loadCourses(String userId) async {
    emit(state.copyWith(state: StudiPassauState.fetching));

    try {
      final courses = await _filesRepo.getCourses(userId);
      courses.sort((c1, c2) {
        final comp = c1.title.compareTo(c2.title);
        if (comp != 0) {
          return comp;
        }
        return c1.number.compareTo(c2.number);
      });

      emit(
        state.copyWith(
          state: StudiPassauState.fetched,
          courses: courses,
        ),
      );
    } on SessionInvalidException {
      emit(state.copyWith(state: StudiPassauState.authenticationError));
    } on io.SocketException {
      emit(state.copyWith(state: StudiPassauState.httpError));
    } catch (e) {
      emit(state.copyWith(state: StudiPassauState.fetchError));
    }
  }

  Future<void> loadCourseTopFolder(Course course) async {
    emit(state.copyWith(state: StudiPassauState.fetching));

    try {
      final topFolder = await _filesRepo.loadCourseTopFolder(course.id);

      final folders = topFolder.item1;
      folders.sort((c1, c2) {
        final comp = c1.name.compareTo(c2.name);
        if (comp != 0) {
          return comp;
        }
        return c1.changeDate.compareTo(c2.changeDate);
      });

      final files = topFolder.item2;
      files.sort((c1, c2) {
        final comp = c1.changeDate.compareTo(c2.changeDate);
        if (comp != 0) {
          return comp;
        }
        return c1.name.compareTo(c2.name);
      });

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
    } catch (e) {
      emit(state.copyWith(state: StudiPassauState.fetchError));
    }
  }

  Future<void> loadFolder(Folder folder, {bool refresh = false}) async {
    emit(state.copyWith(state: StudiPassauState.fetching));

    try {
      final topFolder = await _filesRepo.loadFolder(folder.id);

      final folders = topFolder.item1;
      folders.sort((c1, c2) {
        final comp = c1.name.compareTo(c2.name);
        if (comp != 0) {
          return comp;
        }
        return c1.changeDate.compareTo(c2.changeDate);
      });

      final files = topFolder.item2;
      files.sort((c1, c2) {
        final comp = c1.changeDate.compareTo(c2.changeDate);
        if (comp != 0) {
          return comp;
        }
        return c1.name.compareTo(c2.name);
      });

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
    } catch (e) {
      emit(state.copyWith(state: StudiPassauState.fetchError));
    }
  }

  Future<void> refresh({
    String? userId,
    Course? course,
    Folder? folder,
  }) async {
    if (folder != null) {
      return loadFolder(folder, refresh: true);
    } else if (course != null) {
      return loadCourseTopFolder(course);
    } else if (userId != null) {
      return loadCourses(userId);
    }
  }

  Future<String> downloadFile(
    File file, {
    ProgressListener? onProgress,
    Function? onError,
    void Function(String)? onDone,
  }) async {
    final dirs = (await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        )) ??
        [
          await getExternalStorageDirectory() ??
              await getApplicationDocumentsDirectory(),
        ];
    final toFile = io.File('${dirs[0].path}/${file.name}');

    return _filesRepo.downloadFile(
      toFile,
      Request('GET', Uri.parse('${apiBaseUrl}file/${file.id}/download')),
      onProgress: onProgress,
      onError: onError,
      onDone: onDone,
    );
  }
}
