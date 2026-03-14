import 'dart:convert';
import 'dart:io';

import 'package:catcher_2/catcher_2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/repos/courses_repo.dart';
import 'package:studipassau/bloc/repos/news_repo.dart';
import 'package:studipassau/bloc/repos/storage_repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/models/course.dart';
import 'package:studipassau/models/news.dart';
import 'package:supercharged/supercharged.dart';

class NewsCubit extends Cubit<NewsState> {
  NewsCubit(this._storageRepo, this._newsRepo, this._coursesRepo)
    : super(const NewsState(StudiPassauState.notFetched));

  final StorageRepo _storageRepo;

  final NewsRepo _newsRepo;

  final CoursesRepo _coursesRepo;

  Future<List<News>?> _loadCachedNews() async => _storageRepo
      .getStringList(newsKey)
      ?.map(
        (e) => News.fromJson(
          jsonDecode(e) as Map<String, dynamic>,
          (a) => NewsAttributes.fromJson(a as Map<String, dynamic>),
        ),
      )
      .toList(growable: false);

  Future<List<Course>?> _loadCachedCourses() async => _storageRepo
      .getStringList(courseNewsKey)
      ?.map(
        (e) => Course.fromJson(
          jsonDecode(e) as Map<String, dynamic>,
          (a) => CourseAttributes.fromJson(a as Map<String, dynamic>),
        ),
      )
      .toList(growable: false);

  Future<void> fetchNews({required bool onlineSync}) async {
    emit(state.copyWith(state: StudiPassauState.loading));
    if (state.news == null) {
      try {
        final news = await _loadCachedNews();
        if (news != null) {
          emit(state.copyWith(news: news));
        }
      } catch (e, s) {
        Catcher2.reportCheckedError(e, s);
      }
    }
    if (state.courses == null) {
      try {
        final courses = await _loadCachedCourses();
        if (courses != null) {
          emit(state.copyWith(courses: courses));
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
      final news = await _newsRepo.parseNews();
      emit(state.copyWith(state: StudiPassauState.fetched, news: news));
      await _storageRepo.writeStringList(
        key: newsKey,
        value: news
            .map((n) => jsonEncode(n.toJson((a) => a.toJson())))
            .toList(growable: false),
      );

      final courses = await Future.wait(
        news
            .filter((n) => n.isCourseNews)
            .map((n) => n.courseId)
            .nonNulls
            .map((id) => _coursesRepo.getCourse(id)),
      );
      emit(state.copyWith(courses: courses));
      await _storageRepo.writeStringList(
        key: courseNewsKey,
        value: courses
            .map((n) => jsonEncode(n.toJson((a) => a.toJson())))
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
