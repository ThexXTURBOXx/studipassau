import 'dart:convert';
import 'dart:io';

import 'package:catcher_2/catcher_2.dart';
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

  Future<List<DayMenu>?> _loadCachedMensaPlan() async =>
      (await _storageRepo.getStringList(mensaPlanKey))
          ?.map((e) => DayMenu.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList(growable: false);

  Future<void> fetchMensaPlan({required bool onlineSync}) async {
    emit(state.copyWith(state: StudiPassauState.loading));
    if (state.mensaPlan == null) {
      try {
        final mensaPlan = await _loadCachedMensaPlan();
        if (mensaPlan != null) {
          emit(state.copyWith(mensaPlan: mensaPlan));
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
      final mensaPlan = getPref(mensaSourcePref) == mensaSourcePrefOM
          ? await _mensaRepo.getOpenMensaMeals(openMensaMensaId)
          : await _mensaRepo.getStwnoMeals(stwnoMensaId);
      emit(
        state.copyWith(state: StudiPassauState.fetched, mensaPlan: mensaPlan),
      );
      await _storageRepo.writeStringList(
        key: mensaPlanKey,
        value: mensaPlan.map(jsonEncode).toList(growable: false),
      );
    } on SocketException {
      emit(state.copyWith(state: StudiPassauState.httpError));
    } catch (e, s) {
      Catcher2.reportCheckedError(e, s);
      emit(state.copyWith(state: StudiPassauState.fetchError));
    }
  }
}
