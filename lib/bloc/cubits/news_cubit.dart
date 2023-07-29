import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studipassau/bloc/repos/news_repo.dart';
import 'package:studipassau/bloc/repos/storage_repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/pages/news/widgets/news_item.dart';

class NewsCubit extends Cubit<NewsState> {
  final StorageRepo _storageRepo;

  final NewsRepo _newsRepo;

  NewsCubit(this._storageRepo, this._newsRepo)
      : super(const NewsState(StudiPassauState.notFetched));

  Future<void> loadNews() async {
    final newsCache = _storageRepo.getStringList(newsKey);
    if (newsCache != null) {
      emit(
        state.copyWith(
          state: StudiPassauState.fetched,
          news: newsCache
              .map((e) => News.fromJson(jsonDecode(e)))
              .toList(growable: false),
        ),
      );
    }
  }

  Future<void> fetchNews() async {
    if (state.news == null) {
      emit(state.copyWith(state: StudiPassauState.loading));
      await loadNews();
    }

    emit(state.copyWith(state: StudiPassauState.fetching));

    try {
      final news = await _newsRepo.parseNews();
      await _storageRepo.writeStringList(
        key: newsKey,
        value: news.map(jsonEncode).toList(growable: false),
      );
      emit(
        state.copyWith(
          state: StudiPassauState.fetched,
          news: news,
        ),
      );
    } on SocketException {
      emit(state.copyWith(state: StudiPassauState.httpError));
    } catch (e) {
      emit(state.copyWith(state: StudiPassauState.fetchError));
    }
  }
}
