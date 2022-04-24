import 'package:openmensa/openmensa.dart';
import 'package:studipassau/pages/schedule/widgets/events.dart';

class BlocState {
  final StudiPassauState state;

  const BlocState(this.state);

  bool get finished => state.finished;
}

class LoginState extends BlocState {
  final dynamic userData;

  const LoginState(StudiPassauState state, {this.userData}) : super(state);

  LoginState copyWith({StudiPassauState? state, dynamic userData}) =>
      LoginState(state ?? this.state, userData: userData ?? this.userData);

  String get userId => userData['user_id'].toString();

  String get username => userData['username'].toString();

  String get formattedName => userData['name']['formatted'].toString();

  String get avatarNormal => userData['avatar_normal'].toString();
}

class ScheduleState extends BlocState {
  final List<StudiPassauEvent>? schedule;

  const ScheduleState(StudiPassauState state, {this.schedule}) : super(state);

  ScheduleState copyWith({
    StudiPassauState? state,
    List<StudiPassauEvent>? schedule,
  }) =>
      ScheduleState(state ?? this.state, schedule: schedule ?? this.schedule);

  List<StudiPassauEvent> get events => schedule ?? <StudiPassauEvent>[];
}

class MensaState extends BlocState {
  final List<DayMenu>? mensaPlan;

  const MensaState(StudiPassauState state, {this.mensaPlan}) : super(state);

  MensaState copyWith({StudiPassauState? state, List<DayMenu>? mensaPlan}) =>
      MensaState(state ?? this.state, mensaPlan: mensaPlan ?? this.mensaPlan);

  List<DayMenu> get menu => mensaPlan ?? <DayMenu>[];
}

enum StudiPassauState {
  notAuthenticated,
  loading,
  authenticating,
  authenticated,
  authenticationError,
  notFetched,
  fetching,
  fetched,
  fetchError,
  httpError,
}

extension StudiPassauStateExtension on StudiPassauState {
  bool get finished =>
      this == StudiPassauState.authenticationError ||
      this == StudiPassauState.authenticated ||
      this == StudiPassauState.fetched ||
      this == StudiPassauState.fetchError ||
      this == StudiPassauState.httpError;
}
