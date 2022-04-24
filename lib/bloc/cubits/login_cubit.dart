import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/providers/studip_provider.dart';
import 'package:studipassau/bloc/repos/storage_repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/util/images.dart';

class LoginCubit extends Cubit<LoginState> {
  final StorageRepo _storageRepo;

  LoginCubit(this._storageRepo)
      : super(const LoginState(StudiPassauState.notAuthenticated));

  Future<void> authenticate() async {
    emit(state.copyWith(state: StudiPassauState.loading));
    try {
      final tok = await _storageRepo.readAll();
      dynamic userData;

      if (tok.containsKey(oAuthTokenKey) && tok.containsKey(oAuthSecretKey)) {
        // Read tokens from storage
        try {
          final client = StudIPClient(
            oauthBaseUrl,
            consumerKey,
            consumerSecret,
            accessToken: tok[oAuthTokenKey],
            accessTokenSecret: tok[oAuthSecretKey],
            apiBaseUrl: apiBaseUrl,
          );
          _setApiClient(client);
          userData = await client.apiGetJson('user');
        } catch (e) {
          // Ignore exception, stop loading keys from storage and try to login
          // normally instead, since the saved token is invalid or a server
          // error occurred. In the second case, just try logging in again
          // as well... Doesn't hurt...
        }
      }

      if (userData == null) {
        final client = StudIPClient(
          oauthBaseUrl,
          consumerKey,
          consumerSecret,
          apiBaseUrl: apiBaseUrl,
        );
        final url = await client.getAuthorizationUrl(callbackUrl);
        emit(state.copyWith(state: StudiPassauState.authenticating));
        final params = await FlutterWebAuth.authenticate(
          url: url,
          callbackUrlScheme: callbackUrlScheme,
          preferEphemeral: true,
        );
        final verifier = Uri.parse(params).queryParameters['oauth_verifier']!;
        await client.retrieveAccessToken(verifier);
        await _storageRepo.write(
          key: oAuthTokenKey,
          value: client.accessToken,
        );
        await _storageRepo.write(
          key: oAuthSecretKey,
          value: client.accessTokenSecret,
        );
        _setApiClient(client);
        userData = await client.apiGetJson('user');
      }
      emit(
        state.copyWith(
          state: StudiPassauState.authenticated,
          userData: userData,
        ),
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
