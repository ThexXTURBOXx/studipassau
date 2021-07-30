import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/events/data_event.dart';
import 'package:studipassau/bloc/repository/data_repo.dart';
import 'package:studipassau/bloc/states/data_state.dart';
import 'package:studipassau/pages/schedule/widgets/schedule_parser.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  final DataRepo _repo;

  DataBloc(this._repo) : super(NotFetched());

  @override
  Stream<DataState> mapEventToState(DataEvent event) async* {
    if (event is FetchSchedule) {
      yield Fetching();
      // TODO(HyperSpeeed): Load from file
      try {
        _repo.schedule = await fetchSchedule(_repo.apiClient!, event.userId);
        yield Fetched();
      } on SessionInvalidException {
        yield AuthenticationError();
      } catch (e) {
        yield FetchError();
      }
    }
  }
}
