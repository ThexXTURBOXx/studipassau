import 'dart:convert';
import 'dart:io';

import 'package:catcher_2/catcher_2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/repos/semesters_repo.dart';
import 'package:studipassau/bloc/repos/storage_repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/models/jsonapi.dart';
import 'package:studipassau/models/semester.dart';

class SemestersCubit extends Cubit<SemestersState> {
  SemestersCubit(this._storageRepo, this._semestersRepo)
    : super(const SemestersState(StudiPassauState.notFetched));

  final StorageRepo _storageRepo;

  final SemestersRepo _semestersRepo;

  Future<List<Semester>?> _loadCachedSemesters() async =>
      (await _storageRepo.getStringList(semestersKey))
          ?.map(
            (e) => Semester.fromJson(
              jsonDecode(e) as Map<String, dynamic>,
              (a) => SemesterAttributes.fromJson(a as Map<String, dynamic>),
            ),
          )
          .toList(growable: false);

  Future<void> fetchSemesters({required bool onlineSync}) async {
    emit(state.copyWith(state: StudiPassauState.loading));
    if (state.semesters == null) {
      try {
        final semesters = await _loadCachedSemesters();
        if (semesters != null) {
          emit(state.copyWith(semesters: idMap(semesters)));
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
      final semesters = idMap(await _semestersRepo.getSemesters());

      emit(
        state.copyWith(state: StudiPassauState.fetched, semesters: semesters),
      );

      await _storageRepo.writeStringList(
        key: semestersKey,
        value: semesters.values
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
