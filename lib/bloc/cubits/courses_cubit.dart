import 'dart:convert';
import 'dart:io';

import 'package:catcher_2/catcher_2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/repos/courses_repo.dart';
import 'package:studipassau/bloc/repos/storage_repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/models/course.dart';
import 'package:studipassau/models/course_membership.dart';
import 'package:studipassau/models/jsonapi.dart';

class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit(this._storageRepo, this._coursesRepo)
    : super(const CoursesState(StudiPassauState.notFetched));

  final StorageRepo _storageRepo;

  final CoursesRepo _coursesRepo;

  Future<List<Course>?> _loadCachedCourses(String key) async =>
      (await _storageRepo.getStringList(key))
          ?.map(
            (e) => Course.fromJson(
              jsonDecode(e) as Map<String, dynamic>,
              (a) => CourseAttributes.fromJson(a as Map<String, dynamic>),
            ),
          )
          .toList(growable: false);

  Future<List<CourseMembership>?> _loadCachedCourseMemberships() async =>
      (await _storageRepo.getStringList(courseMembershipsKey))
          ?.map(
            (e) => CourseMembership.fromJson(
              jsonDecode(e) as Map<String, dynamic>,
              (a) => CourseMembershipAttributes.fromJson(
                a as Map<String, dynamic>,
              ),
            ),
          )
          .toList(growable: false);

  Future<void> fetchCourses(
    String userId, {
    required bool onlineSync,
    Set<String> extra = const {},
  }) async {
    emit(state.copyWith(state: StudiPassauState.loading));
    if (state.courses == null) {
      try {
        final courses = await _loadCachedCourses(coursesKey);
        if (courses != null) {
          emit(state.copyWith(courses: idMap(courses)));
        }
      } catch (e, s) {
        Catcher2.reportCheckedError(e, s);
      }
    }

    if (state.extraCourses == null) {
      try {
        final extraCourses = await _loadCachedCourses(extraCoursesKey);
        if (extraCourses != null) {
          emit(state.copyWith(extraCourses: idMap(extraCourses)));
        }
      } catch (e, s) {
        Catcher2.reportCheckedError(e, s);
      }
    }

    if (state.courseMemberships == null) {
      try {
        final courseMemberships = await _loadCachedCourseMemberships();
        if (courseMemberships != null) {
          emit(state.copyWith(courseMemberships: idMap(courseMemberships)));
        }
      } catch (e, s) {
        Catcher2.reportCheckedError(e, s);
      }
    }

    if (!onlineSync) {
      emit(state.copyWith(state: StudiPassauState.fetched));
      return;
    }

    emit(state.copyWith(state: StudiPassauState.fetching));
    try {
      final results = await Future.wait([
        _coursesRepo.getCourses(userId),
        _coursesRepo.getCourseMemberships(userId),
      ]);
      final courses = idMap(results[0] as List<Course>);
      final courseMemberships = idMap(results[1] as List<CourseMembership>);

      emit(
        state.copyWith(
          state: StudiPassauState.fetched,
          courses: courses,
          courseMemberships: courseMemberships,
        ),
      );

      await _storageRepo.writeStringList(
        key: coursesKey,
        value: courses.values
            .map((c) => jsonEncode(c.toJson((a) => a.toJson())))
            .toList(growable: false),
      );
      await _storageRepo.writeStringList(
        key: courseMembershipsKey,
        value: courseMemberships.values
            .map((c) => jsonEncode(c.toJson((a) => a.toJson())))
            .toList(growable: false),
      );

      final extraCourseIds = extra.where((id) => !courses.containsKey(id));
      if (extraCourseIds.isEmpty) return;

      final results2 = await Future.wait(
        extraCourseIds.map((id) => _coursesRepo.getCourse(id)),
      );
      final extraCourses = {...state.extraCoursesOrEmpty, ...idMap(results2)};

      emit(
        state.copyWith(
          state: StudiPassauState.fetched,
          extraCourses: extraCourses,
        ),
      );

      await _storageRepo.writeStringList(
        key: extraCoursesKey,
        value: extraCourses.values
            .map((c) => jsonEncode(c.toJson((a) => a.toJson())))
            .toList(growable: false),
      );
    } on SessionInvalidException {
      emit(state.copyWith(state: StudiPassauState.authenticationError));
    } on SocketException {
      emit(state.copyWith(state: StudiPassauState.httpError));
    } catch (e, s) {
      Catcher2.reportCheckedError(e, s);
      emit(state.copyWith(state: StudiPassauState.fetchError));
    }
  }
}
