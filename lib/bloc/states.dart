import 'package:openmensa/openmensa.dart';
import 'package:studipassau/pages/schedule/widgets/events.dart';

class BlocState {
  final StudiPassauState state;

  const BlocState(this.state);

  bool get finished => state.finished;

  bool get errored => state.errored;
}

class LoginState extends BlocState {
  final dynamic userData;

  const LoginState(super.state, {this.userData});

  LoginState copyWith({StudiPassauState? state, dynamic userData}) =>
      LoginState(state ?? this.state, userData: userData ?? this.userData);

  String get userId => userData['user_id'].toString();

  String get username => userData['username'].toString();

  String get formattedName => userData['name']['formatted'].toString();

  String get avatarNormal => userData['avatar_normal'].toString();
}

class ScheduleState extends BlocState {
  final List<StudiPassauEvent>? schedule;

  const ScheduleState(super.state, {this.schedule});

  ScheduleState copyWith({
    StudiPassauState? state,
    List<StudiPassauEvent>? schedule,
  }) =>
      ScheduleState(state ?? this.state, schedule: schedule ?? this.schedule);

  List<StudiPassauEvent> get events => schedule ?? <StudiPassauEvent>[];
}

class MensaState extends BlocState {
  final List<DayMenu>? mensaPlan;

  const MensaState(super.state, {this.mensaPlan});

  MensaState copyWith({StudiPassauState? state, List<DayMenu>? mensaPlan}) =>
      MensaState(state ?? this.state, mensaPlan: mensaPlan ?? this.mensaPlan);

  List<DayMenu> get menu => mensaPlan ?? <DayMenu>[];
}

enum StudiPassauState {
  notAuthenticated,
  loading,
  authenticating,
  authenticated(finished: true),
  authenticationError(finished: true, errored: true),
  notFetched,
  fetching,
  fetched(finished: true),
  fetchError(finished: true, errored: true),
  httpError(finished: true, errored: true);

  final bool finished;
  final bool errored;

  const StudiPassauState({
    this.finished = false,
    this.errored = false,
  });
}
