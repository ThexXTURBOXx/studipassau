import 'package:equatable/equatable.dart';

abstract class OAuthState extends Equatable {
  final List _props;

  const OAuthState([this._props = const []]);

  @override
  List<Object> get props => _props;
}

class NotAuthenticated extends OAuthState {}

class Authenticating extends OAuthState {}

class Authenticated extends OAuthState {}

class AuthenticationError extends OAuthState {}
