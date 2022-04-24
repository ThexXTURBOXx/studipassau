import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studipassau/bloc/repos/mensa_repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';

class MensaCubit extends Cubit<MensaState> {
  final OpenMensaRepo _openMensaRepo;

  MensaCubit(this._openMensaRepo)
      : super(const MensaState(StudiPassauState.notFetched));

  Future<void> fetchMensaPlan() async {
    emit(state.copyWith(state: StudiPassauState.fetching));
    // TODO(HyperSpeeed): Load from file
    try {
      emit(
        state.copyWith(
          state: StudiPassauState.fetched,
          mensaPlan: await _openMensaRepo.getMealsOfCanteen(openMensaMensaId),
        ),
      );
    } catch (e) {
      emit(state.copyWith(state: StudiPassauState.fetchError));
    }
  }
}
