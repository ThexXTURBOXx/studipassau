import 'dart:io';

import 'package:catcher_2/catcher_2.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oauth2_client/oauth2_exception.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/states.dart';

class ErroringCubit<State extends BlocState> extends Cubit<State> {
  ErroringCubit(super.initialState);

  void handleLoginError(Object e, StackTrace s) {
    if (e is StateError) {
      emit(state.copyWith(state: StudiPassauState.httpError));
    } else if (e is SocketException) {
      emit(state.copyWith(state: StudiPassauState.httpError));
    } else {
      final extraData = <String, dynamic>{};
      if (e is OAuth2Exception) {
        final cause = e.cause;
        if (cause is PlatformException && cause.code == 'CANCELED') {
          emit(state.copyWith(state: StudiPassauState.authenticationError));
          return;
        }
        extraData['origTrace'] = e.causeTrace;
      }
      Catcher2.reportCheckedError(e, s, extraData: extraData);
      emit(state.copyWith(state: StudiPassauState.authenticationError));
    }
  }

  void handleFetchError(Object e, StackTrace s) {
    if (e is SessionInvalidException) {
      emit(state.copyWith(state: StudiPassauState.authenticationError));
    } else if (e is SocketException) {
      emit(state.copyWith(state: StudiPassauState.httpError));
    } else {
      final extraData = <String, dynamic>{};
      if (e is OAuth2Exception) {
        final cause = e.cause;
        if (cause is PlatformException && cause.code == 'CANCELED') {
          emit(state.copyWith(state: StudiPassauState.fetchError));
          return;
        }
        extraData['origTrace'] = e.causeTrace;
      }
      Catcher2.reportCheckedError(e, s, extraData: extraData);
      emit(state.copyWith(state: StudiPassauState.fetchError));
    }
  }
}
