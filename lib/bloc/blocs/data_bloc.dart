import 'package:StudiPassau/bloc/events/data_event.dart';
import 'package:StudiPassau/bloc/repository/data_repo.dart';
import 'package:StudiPassau/bloc/states/data_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studip/studip.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  final DataRepo _repo;

  DataBloc(this._repo)
      : assert(_repo != null),
        super(NotFetched());

  @override
  Stream<DataState> mapEventToState(DataEvent event) async* {
    if (event is FetchSchedule) {
      yield Fetching();
      // TODO(HyperSpeeed): Load from file
      try {
        _repo.schedule =
            await _repo.apiClient.apiGetJson('user/${event.userId}/schedule');
        yield Fetched();
      } on SessionInvalidException {
        yield AuthenticationError();
      } catch (e) {
        yield FetchError();
      }
    }
  }
}
