import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:catcher_2/catcher_2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/cubits/courses_cubit.dart';
import 'package:studipassau/bloc/repos/news_repo.dart';
import 'package:studipassau/bloc/repos/storage_repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/models/jsonapi.dart';
import 'package:studipassau/models/news.dart';

class NewsCubit extends Cubit<NewsState> {
  NewsCubit(this._coursesCubit, this._storageRepo, this._newsRepo)
    : super(const NewsState(StudiPassauState.notFetched));

  final CoursesCubit _coursesCubit;

  final StorageRepo _storageRepo;

  final NewsRepo _newsRepo;

  Future<List<News>?> _loadCachedNews() async =>
      (await _storageRepo.getStringList(newsKey))
          ?.map(
            (e) => News.fromJson(
              jsonDecode(e) as Map<String, dynamic>,
              (a) => NewsAttributes.fromJson(a as Map<String, dynamic>),
            ),
          )
          .toList(growable: false);

  Future<void> fetchNews(String userId, {required bool onlineSync}) async {
    emit(state.copyWith(state: StudiPassauState.loading));
    if (state.news == null) {
      try {
        final news = await _loadCachedNews();
        if (news != null) {
          emit(state.copyWith(news: idMap(news)));
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
      final news = idMap(await _newsRepo.parseNews());
      emit(state.copyWith(state: StudiPassauState.fetched, news: news));

      unawaited(
        _coursesCubit.fetchCourses(
          userId,
          onlineSync: onlineSync,
          extra: news.values
              .where((n) => n.isCourseNews)
              .map((n) => n.courseId)
              .nonNulls
              .toSet(),
        ),
      );

      await _storageRepo.writeStringList(
        key: newsKey,
        value: news.values
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
