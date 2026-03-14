import 'dart:convert';
import 'dart:io';

import 'package:catcher_2/catcher_2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/repos/schedule_repo.dart';
import 'package:studipassau/bloc/repos/storage_repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/models/studipassau_event.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit(this._storageRepo, this._scheduleRepo)
    : super(const ScheduleState(StudiPassauState.notFetched));

  final StorageRepo _storageRepo;

  final ScheduleRepo _scheduleRepo;

  Future<List<StudiPassauEvent>?> _loadCachedSchedule() async => _storageRepo
      .getStringList(scheduleKey)
      ?.map((e) => StudiPassauEvent.fromJson(jsonDecode(e)))
      .toList(growable: false);

  Future<void> fetchSchedule(String userId, {required bool onlineSync}) async {
    emit(state.copyWith(state: StudiPassauState.loading));
    if (state.schedule == null) {
      try {
        final schedule = await _loadCachedSchedule();
        if (schedule != null) {
          emit(state.copyWith(schedule: schedule));
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
      final schedule = await _scheduleRepo.parseSchedule(userId);
      emit(state.copyWith(state: StudiPassauState.fetched, schedule: schedule));
      await _storageRepo.writeStringList(
        key: scheduleKey,
        value: schedule.map(jsonEncode).toList(growable: false),
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
