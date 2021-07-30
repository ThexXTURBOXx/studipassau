import 'package:equatable/equatable.dart';

abstract class OAuthEvent extends Equatable {
  final List _props;

  const OAuthEvent([this._props = const []]);

  @override
  List<Object> get props => _props as List<Object>;
}

class Authenticate extends OAuthEvent {}
