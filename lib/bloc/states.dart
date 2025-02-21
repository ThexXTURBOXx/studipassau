import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:openmensa/openmensa.dart';
import 'package:studipassau/pages/files/widgets/course.dart';
import 'package:studipassau/pages/files/widgets/file.dart';
import 'package:studipassau/pages/files/widgets/folder.dart';
import 'package:studipassau/pages/news/widgets/news_item.dart';
import 'package:studipassau/pages/schedule/widgets/events.dart';

class BlocState {
  const BlocState(this.state);

  final StudiPassauState state;

  bool get finished => state.finished;

  bool get errored => state.errored;
}

class LoginState extends BlocState {
  const LoginState(super.state, {this.userData});

  final dynamic userData;

  LoginState copyWith({StudiPassauState? state, userData}) =>
      LoginState(state ?? this.state, userData: userData ?? this.userData);

  String get userId => userData['data']['id'].toString();

  String get username => userData['data']['attributes']['username'].toString();

  String get formattedName =>
      userData['data']['attributes']['formatted-name'].toString();

  String get avatarNormal =>
      userData['data']['meta']['avatar']['normal'].toString();
}

class ScheduleState extends BlocState {
  const ScheduleState(super.state, {this.schedule});

  final List<StudiPassauEvent>? schedule;

  ScheduleState copyWith({
    StudiPassauState? state,
    List<StudiPassauEvent>? schedule,
  }) => ScheduleState(state ?? this.state, schedule: schedule ?? this.schedule);

  List<StudiPassauEvent> get events => schedule ?? <StudiPassauEvent>[];
}

class MensaState extends BlocState {
  const MensaState(super.state, {this.mensaPlan});

  final List<DayMenu>? mensaPlan;

  MensaState copyWith({StudiPassauState? state, List<DayMenu>? mensaPlan}) =>
      MensaState(state ?? this.state, mensaPlan: mensaPlan ?? this.mensaPlan);

  List<DayMenu> get menu => mensaPlan ?? <DayMenu>[];
}

class FilesState extends BlocState {
  FilesState(
    super.state, {
    required this.currentFolders,
    this.currentCourse,
    this.courses = const [],
    this.files = const [],
    this.folders = const [],
  });

  Course? currentCourse;
  final List<Course> courses;
  final List<File> files;
  final List<Folder> folders;
  final Queue<Folder> currentFolders;

  FolderState get folderState =>
      currentFolder != null
          ? FolderState.folder
          : currentCourse != null
          ? FolderState.courseHome
          : FolderState.home;

  Folder? get currentFolder => currentFolders.firstOrNull;

  bool goUp() {
    switch (folderState) {
      case FolderState.home:
        return true;
      case FolderState.courseHome:
        currentCourse = null;
      case FolderState.folder:
        currentFolders.removeFirst();
    }
    return false;
  }

  FilesState copyWith({
    StudiPassauState? state,
    Course? currentCourse,
    List<Course>? courses,
    List<File>? files,
    List<Folder>? folders,
    Queue<Folder>? currentFolders,
  }) => FilesState(
    state ?? this.state,
    currentCourse: currentCourse ?? this.currentCourse,
    courses: courses ?? this.courses,
    files: files ?? this.files,
    folders: folders ?? this.folders,
    currentFolders: currentFolders ?? this.currentFolders,
  );
}

enum FolderState { home, courseHome, folder }

class NewsState extends BlocState {
  const NewsState(super.state, {this.news});

  final List<News>? news;

  NewsState copyWith({StudiPassauState? state, List<News>? news}) =>
      NewsState(state ?? this.state, news: news ?? this.news);

  List<News> get newsOrEmpty => news ?? <News>[];
}

enum StudiPassauState {
  notAuthenticated,
  loading,
  authenticating,
  authenticated(finished: true),
  authenticationError(finished: true, errored: true),
  notFetched,
  fetching,
  fetched(finished: true),
  fetchError(finished: true, errored: true),
  httpError(finished: true, errored: true);

  const StudiPassauState({this.finished = false, this.errored = false});

  final bool finished;
  final bool errored;
}
