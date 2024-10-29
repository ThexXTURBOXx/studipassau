import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/providers/studip_provider.dart';
import 'package:studipassau/bloc/repos/storage_repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/env/env.dart';
import 'package:studipassau/util/images.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._storageRepo)
      : super(const LoginState(StudiPassauState.notAuthenticated));

  final StorageRepo _storageRepo;

  Future<void> authenticate() async {
    emit(state.copyWith(state: StudiPassauState.loading));
    try {
      final cfgJson = _storageRepo.getString(userDataKey);
      dynamic userData;

      if (cfgJson != null) {
        userData = jsonDecode(cfgJson);
        emit(state.copyWith(userData: userData));
      }

      emit(state.copyWith(state: StudiPassauState.authenticating));
      final client = StudIPClient(
        oAuthBaseUrl: studIpProviderUrl,
        redirectUri: 'studipassau://oauth_callback',
        customUriScheme: 'studipassau',
        clientId: Env.clientId,
        //clientSecret: Env.clientSecret,
        apiBaseUrl: apiBaseUrl,
      );
      _setApiClient(client);
      userData = await client.apiGetJson('users/me');

      emit(
        state.copyWith(
          state: StudiPassauState.authenticated,
          userData: userData,
        ),
      );
      await _storageRepo.writeString(
        key: userDataKey,
        value: jsonEncode(userData),
      );
    } catch (e) {
      if (e is StateError || e is SocketException) {
        emit(state.copyWith(state: StudiPassauState.httpError));
      } else {
        emit(state.copyWith(state: StudiPassauState.authenticationError));
      }
    }
  }

  void _setApiClient(StudIPClient client) {
    StudIPDataProvider.apiClient = client;
    StudIPHttpFileService.apiClient = client;
    StudIPCacheManager.construct();
  }
}
