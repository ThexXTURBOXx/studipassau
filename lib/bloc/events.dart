import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  final List _props;

  const LoginEvent([this._props = const []]);

  @override
  List<Object> get props => _props as List<Object>;
}

abstract class ScheduleEvent extends Equatable {
  final List _props;

  const ScheduleEvent([this._props = const []]);

  @override
  List<Object> get props => _props as List<Object>;
}

abstract class MensaPlanEvent extends Equatable {
  final List _props;

  const MensaPlanEvent([this._props = const []]);

  @override
  List<Object> get props => _props as List<Object>;
}

class Authenticate extends LoginEvent {}

class FetchSchedule extends ScheduleEvent {
  final String _userId;

  FetchSchedule(this._userId) : super([_userId]);

  String get userId => _userId;
}

class FetchMensaPlan extends MensaPlanEvent {}
