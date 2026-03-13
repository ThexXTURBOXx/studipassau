import 'dart:convert';
import 'dart:io';

import 'package:catcher_2/catcher_2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/repos/courses_repo.dart';
import 'package:studipassau/bloc/repos/news_repo.dart';
import 'package:studipassau/bloc/repos/storage_repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/pages/news/widgets/news_item.dart';
import 'package:supercharged/supercharged.dart';

class NewsCubit extends Cubit<NewsState> {
  NewsCubit(this._storageRepo, this._newsRepo, this._coursesRepo)
    : super(const NewsState(StudiPassauState.notFetched));

  final StorageRepo _storageRepo;

  final NewsRepo _newsRepo;

  final CoursesRepo _coursesRepo;

  Future<void> loadNews() async {
    final newsCache = _storageRepo.getStringList(newsKey);
    if (newsCache != null) {
      emit(
        state.copyWith(
          state: StudiPassauState.fetched,
          news: newsCache
              .map(
                (e) => News.fromJson(
                  jsonDecode(e) as Map<String, dynamic>,
                  (a) => NewsAttributes.fromJson(a as Map<String, dynamic>),
                ),
              )
              .toList(growable: false),
        ),
      );
    }
  }

  Future<void> fetchNews({required bool onlineSync}) async {
    if (state.news == null) {
      try {
        emit(state.copyWith(state: StudiPassauState.loading));
        await loadNews();
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
      await _storageRepo.writeStringList(
        key: newsKey,
        value: news
            .map((n) => jsonEncode(n.toJson((a) => a.toJson())))
            .toList(growable: false),
      );
      emit(state.copyWith(state: StudiPassauState.fetched, news: news));

      final courses = await Future.wait(
        news
            .filter((n) => n.isCourseNews)
            .map((n) => n.courseId)
            .nonNulls
            .map((id) => _coursesRepo.getCourse(id)),
      );
      emit(state.copyWith(state: StudiPassauState.fetched, courses: courses));
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
