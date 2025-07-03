import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openmensa/openmensa.dart';
import 'package:studipassau/bloc/repos/mensa_repo.dart';
import 'package:studipassau/bloc/repos/storage_repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/pages/settings/settings.dart';

class MensaCubit extends Cubit<MensaState> {
  MensaCubit(this._storageRepo, this._mensaRepo)
    : super(const MensaState(StudiPassauState.notFetched));

  final StorageRepo _storageRepo;

  final MensaRepo _mensaRepo;

  Future<void> loadMensaPlan() async {
    final mensaCache = _storageRepo.getStringList(mensaPlanKey);
    if (mensaCache != null) {
      emit(
        state.copyWith(
          state: StudiPassauState.fetched,
          mensaPlan: mensaCache
              .map((e) => DayMenu.fromJson(jsonDecode(e)))
              .toList(growable: false),
        ),
      );
    }
  }

  Future<void> fetchMensaPlan({required bool onlineSync}) async {
    if (state.mensaPlan == null) {
      emit(state.copyWith(state: StudiPassauState.loading));
      await loadMensaPlan();
    }

    if (!onlineSync) {
      emit(state.copyWith(state: StudiPassauState.fetched));
      return;
    }

    emit(state.copyWith(state: StudiPassauState.fetching));

    try {
      final mensaPlan = getPref(mensaSourcePref) == mensaSourcePrefOM
          ? await _mensaRepo.getOpenMensaMeals(openMensaMensaId)
          : await _mensaRepo.getStwnoMeals(stwnoMensaId);
      await _storageRepo.writeStringList(
        key: mensaPlanKey,
        value: mensaPlan.map(jsonEncode).toList(growable: false),
      );
      emit(
        state.copyWith(state: StudiPassauState.fetched, mensaPlan: mensaPlan),
      );
    } on SocketException {
      emit(state.copyWith(state: StudiPassauState.httpError));
    } catch (e) {
      emit(state.copyWith(state: StudiPassauState.fetchError));
    }
  }
}
