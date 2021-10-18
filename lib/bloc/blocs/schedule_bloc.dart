import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/events.dart';
import 'package:studipassau/bloc/repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/pages/schedule/widgets/schedule_parser.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, StudiPassauState> {
  static final StudiPassauRepo _repo = StudiPassauRepo();

  ScheduleBloc() : super(StudiPassauState.notFetched);

  @override
  Stream<StudiPassauState> mapEventToState(ScheduleEvent event) async* {
    if (event is FetchSchedule) {
      yield StudiPassauState.fetching;
      // TODO(HyperSpeeed): Load from file
      try {
        _repo.schedule = await fetchSchedule(_repo.apiClient, event.userId);
        yield StudiPassauState.fetched;
      } on SessionInvalidException {
        yield StudiPassauState.authenticationError;
      } catch (e) {
        yield StudiPassauState.fetchError;
      }
    }
  }
}
