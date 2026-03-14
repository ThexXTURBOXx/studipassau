import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:openmensa/openmensa.dart';
import 'package:studipassau/models/course.dart';
import 'package:studipassau/models/file_ref.dart';
import 'package:studipassau/models/folder.dart';
import 'package:studipassau/models/news.dart';
import 'package:studipassau/models/studipassau_event.dart';
import 'package:studipassau/models/user.dart';

class BlocState {
  const BlocState(this.state);

  final StudiPassauState state;

  bool get finished => state.finished;

  bool get errored => state.errored;
}

class LoginState extends BlocState {
  const LoginState(super.state, {this.me});

  final User? me;

  LoginState copyWith({StudiPassauState? state, User? me}) =>
      LoginState(state ?? this.state, me: me ?? this.me);

  String? get userId => me?.id;

  String? get username => me?.attributes.username;

  String? get formattedName => me?.attributes.formattedName;

  String? get avatarNormal => me?.meta?['avatar']?['normal']?.toString();
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
  final List<FileRef> files;
  final List<Folder> folders;
  final Queue<Folder> currentFolders;

  FolderState get folderState => currentFolder != null
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
    List<FileRef>? files,
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
  const NewsState(super.state, {this.news, this.courses});

  final List<News>? news;

  final List<Course>? courses;

  NewsState copyWith({
    StudiPassauState? state,
    List<News>? news,
    List<Course>? courses,
  }) => NewsState(
    state ?? this.state,
    news: news ?? this.news,
    courses: courses ?? this.courses,
  );

  List<News> get newsOrEmpty => news ?? <News>[];

  Course? getCourse(String id) => courses?.firstWhere((c) => c.id == id);

  String? getCourseTitle(String id) => getCourse(id)?.attributes.title;
}

enum StudiPassauState {
  /// Only used in login phase (app start = not authenticated yet)
  notAuthenticated,

  /// Only used in login phase (we are currently authenticating against backend)
  authenticating,

  /// Only used in login phase (authentication was finished successfully)
  authenticated(finished: true),

  /// No data is fetched or loaded yet (default state)
  notFetched,

  /// Used when something is being loaded from cache
  loading,

  /// Cache load has finished and (updated) data is being fetched from the server
  fetching,

  /// (Updated) data was fetched from the server successfully
  fetched(finished: true),

  /// There was an authentication error, e.g., the session is invalid
  authenticationError(finished: true, errored: true),

  /// There was a connectivity issue during fetching
  httpError(finished: true, errored: true),

  /// There was some miscellaneous error during fetching
  fetchError(finished: true, errored: true);

  const StudiPassauState({this.finished = false, this.errored = false});

  final bool finished;
  final bool errored;
}
