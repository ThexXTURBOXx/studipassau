import 'package:equatable/equatable.dart';

abstract class DataState extends Equatable {
  final List _props;

  const DataState([this._props = const []]);

  @override
  List<Object> get props => _props;
}

class NotFetched extends DataState {}

class Fetching extends DataState {}

class Fetched extends DataState {}

class AuthenticationError extends DataState {}

class FetchError extends DataState {}
