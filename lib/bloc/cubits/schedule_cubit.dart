import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/repos/schedule_repo.dart';
import 'package:studipassau/bloc/repos/storage_repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/pages/schedule/widgets/events.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit(this._storageRepo, this._scheduleRepo)
      : super(const ScheduleState(StudiPassauState.notFetched));

  final StorageRepo _storageRepo;

  final ScheduleRepo _scheduleRepo;

  Future<void> loadSchedule() async {
    final scheduleCache = _storageRepo.getStringList(scheduleKey);
    if (scheduleCache != null) {
      emit(
        state.copyWith(
          state: StudiPassauState.fetched,
          schedule: scheduleCache
              .map((e) => StudiPassauEvent.fromJson(jsonDecode(e)))
              .toList(growable: false),
        ),
      );
    }
  }

  Future<void> fetchSchedule(String userId, {required bool onlineSync}) async {
    if (state.schedule == null) {
      emit(state.copyWith(state: StudiPassauState.loading));
      await loadSchedule();
    }

    if (!onlineSync) {
      emit(state.copyWith(state: StudiPassauState.fetched));
      return;
    }

    emit(state.copyWith(state: StudiPassauState.fetching));

    try {
      final schedule = await _scheduleRepo.parseSchedule(userId);
      await _storageRepo.writeStringList(
        key: scheduleKey,
        value: schedule.map(jsonEncode).toList(growable: false),
      );
      emit(
        state.copyWith(
          state: StudiPassauState.fetched,
          schedule: schedule,
        ),
      );
    } on SessionInvalidException {
      emit(state.copyWith(state: StudiPassauState.authenticationError));
    } on SocketException {
      emit(state.copyWith(state: StudiPassauState.httpError));
    } catch (e) {
      emit(state.copyWith(state: StudiPassauState.fetchError));
    }
  }
}
