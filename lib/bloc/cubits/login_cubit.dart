import 'dart:convert';
import 'dart:io';

import 'package:catcher_2/catcher_2.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry/sentry.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/providers/studip_provider.dart';
import 'package:studipassau/bloc/repos/storage_repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/env/env.dart';
import 'package:studipassau/models/jsonapi.dart';
import 'package:studipassau/models/user.dart';
import 'package:studipassau/util/images.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._storageRepo)
    : super(const LoginState(StudiPassauState.notAuthenticated));

  final StorageRepo _storageRepo;

  Future<User?> _loadCachedMe() async {
    final cfgJson = _storageRepo.getString(userDataKey);
    return cfgJson == null
        ? null
        : User.fromJson(
            jsonDecode(cfgJson) as Map<String, dynamic>,
            (a) => UserAttributes.fromJson(a as Map<String, dynamic>),
          );
  }

  Future<void> authenticate() async {
    emit(state.copyWith(state: StudiPassauState.loading));
    try {
      final me = await _loadCachedMe();
      if (me != null) {
        emit(state.copyWith(me: me));
      }
    } catch (e, s) {
      Catcher2.reportCheckedError(e, s);
    }

    emit(state.copyWith(state: StudiPassauState.authenticating));
    try {
      final client = StudIPClient(
        oAuthBaseUrl: studIpProviderUrl,
        redirectUri: 'studipassau://oauth_callback',
        customUriScheme: 'studipassau',
        clientId: Env.clientId,
        //clientSecret: Env.clientSecret,
        apiBaseUrl: apiBaseUrl,
      );
      _setApiClient(client);

      User me = parseObject(
        await client.apiGetJson('users/me'),
        (item) => UserAttributes.fromJson(item as Map<String, dynamic>),
      );
      emit(state.copyWith(state: StudiPassauState.authenticated, me: me));

      _setMe(me);
      await _storageRepo.writeString(
        key: userDataKey,
        value: jsonEncode(me.toJson((a) => a.toJson())),
      );
    } on StateError {
      emit(state.copyWith(state: StudiPassauState.httpError));
    } on SocketException {
      emit(state.copyWith(state: StudiPassauState.httpError));
    } catch (e, s) {
      Catcher2.reportCheckedError(e, s);
      emit(state.copyWith(state: StudiPassauState.authenticationError));
    }
  }

  void _setApiClient(StudIPClient client) {
    StudIPDataProvider.apiClient = client;
    StudIPHttpFileService.apiClient = client;
  }

  void _setMe(User user) {
    sentryHandler.userContext = SentryUser(
      id: user.id,
      username: user.attributes.username,
      email: user.attributes.email,
      name: user.attributes.formattedName,
    );
  }
}
