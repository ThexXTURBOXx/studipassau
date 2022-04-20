import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studipassau/bloc/events.dart';
import 'package:studipassau/bloc/repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';

class MensaBloc extends Bloc<MensaPlanEvent, StudiPassauState> {
  static final StudiPassauRepo _repo = StudiPassauRepo();

  MensaBloc() : super(StudiPassauState.notFetched) {
    on<FetchMensaPlan>(_fetchMensaPlan);
  }

  Future<void> _fetchMensaPlan(
    MensaPlanEvent event,
    Emitter<StudiPassauState> emit,
  ) async {
    if (event is FetchMensaPlan) {
      emit(StudiPassauState.fetching);
      // TODO(HyperSpeeed): Load from file
      try {
        _repo.mensaPlan =
            await _repo.mensaClient.getMealsOfCanteen(openMensaMensaId);
        emit(StudiPassauState.fetched);
      } catch (e) {
        emit(StudiPassauState.fetchError);
      }
    }
  }
}
