import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studipassau/bloc/repos/mensa_repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/pages/settings/settings.dart';

class MensaCubit extends Cubit<MensaState> {
  final MensaRepo _mensaRepo;

  MensaCubit(this._mensaRepo)
      : super(const MensaState(StudiPassauState.notFetched));

  Future<void> fetchMensaPlan() async {
    emit(state.copyWith(state: StudiPassauState.fetching));
    // TODO(HyperSpeeed): Load from file
    try {
      emit(
        state.copyWith(
          state: StudiPassauState.fetched,
          mensaPlan: getPref(mensaSourcePref) == mensaSourcePrefOM
              ? await _mensaRepo.getOpenMensaMeals(openMensaMensaId)
              : await _mensaRepo.getStwnoMeals(stwnoMensaId),
        ),
      );
    } catch (e) {
      emit(state.copyWith(state: StudiPassauState.fetchError));
    }
  }
}
