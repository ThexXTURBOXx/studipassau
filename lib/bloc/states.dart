import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:openmensa/openmensa.dart';
import 'package:studipassau/models/course.dart';
import 'package:studipassau/models/course_membership.dart';
import 'package:studipassau/models/file_ref.dart';
import 'package:studipassau/models/folder.dart';
import 'package:studipassau/models/news.dart';
import 'package:studipassau/models/semester.dart';
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
    this.files = const [],
    this.folders = const [],
  });

  final Queue<Folder> currentFolders;
  Course? currentCourse;
  final List<FileRef> files;
  final List<Folder> folders;

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
    Queue<Folder>? currentFolders,
    Course? currentCourse,
    List<FileRef>? files,
    List<Folder>? folders,
  }) => FilesState(
    state ?? this.state,
    currentFolders: currentFolders ?? this.currentFolders,
    currentCourse: currentCourse ?? this.currentCourse,
    files: files ?? this.files,
    folders: folders ?? this.folders,
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

class CoursesState extends BlocState {
  const CoursesState(
    super.state, {
    this.courses,
    this.extraCourses,
    this.courseMemberships,
  });

  final Map<String, Course>? courses;

  final Map<String, Course>? extraCourses;

  final Map<String, CourseMembership>? courseMemberships;

  CoursesState copyWith({
    StudiPassauState? state,
    Map<String, Course>? courses,
    Map<String, Course>? extraCourses,
    Map<String, CourseMembership>? courseMemberships,
  }) => CoursesState(
    state ?? this.state,
    courses: courses ?? this.courses,
    extraCourses: extraCourses ?? this.extraCourses,
    courseMemberships: courseMemberships ?? this.courseMemberships,
  );

  Map<String, Course> get allCourses => {
    ...(courses ?? {}),
    ...(extraCourses ?? {}),
  };
}

class SemestersState extends BlocState {
  const SemestersState(super.state, {this.semesters});

  final Map<String, Semester>? semesters;

  SemestersState copyWith({
    StudiPassauState? state,
    Map<String, Semester>? semesters,
  }) => SemestersState(
    state ?? this.state,
    semesters: semesters ?? this.semesters,
  );
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
