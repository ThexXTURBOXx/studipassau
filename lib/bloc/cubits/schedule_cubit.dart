import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/repos/studip_repo.dart';
import 'package:studipassau/bloc/states.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final StudIPRepo _studIPRepo;

  ScheduleCubit(this._studIPRepo)
      : super(const ScheduleState(StudiPassauState.notFetched));

  Future<void> fetchSchedule(String userId) async {
    emit(state.copyWith(state: StudiPassauState.fetching));
    // TODO(HyperSpeeed): Load from file
    try {
      emit(
        state.copyWith(
          state: StudiPassauState.fetched,
          schedule: await _studIPRepo.parseSchedule(userId),
        ),
      );
    } on SessionInvalidException {
      emit(state.copyWith(state: StudiPassauState.authenticationError));
    } catch (e) {
      emit(state.copyWith(state: StudiPassauState.fetchError));
    }
  }
}
