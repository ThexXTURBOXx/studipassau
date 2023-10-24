import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
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
      final tok = await _storageRepo.readAllSecure();
      final cfgJson = _storageRepo.getString(userDataKey);
      dynamic userData;
      var fetched = false;

      if (cfgJson != null) {
        userData = jsonDecode(cfgJson);
        emit(state.copyWith(userData: userData));
      }

      if (tok.containsKey(oAuthTokenKey) && tok.containsKey(oAuthSecretKey)) {
        // Read tokens from storage
        try {
          final client = StudIPClient(
            oauthBaseUrl,
            Env.consumerKey,
            Env.consumerSecret,
            accessToken: tok[oAuthTokenKey],
            accessTokenSecret: tok[oAuthSecretKey],
            apiBaseUrl: apiBaseUrl,
          );
          _setApiClient(client);
          userData = await client.apiGetJson('user');
          fetched = true;
        } catch (e) {
          // Ignore exception, stop loading keys from storage and try to login
          // normally instead, since the saved token is invalid or a server
          // error occurred. In the second case, just try logging in again
          // as well... Doesn't hurt...
        }
      }

      if (!fetched) {
        final client = StudIPClient(
          oauthBaseUrl,
          Env.consumerKey,
          Env.consumerSecret,
          apiBaseUrl: apiBaseUrl,
        );
        final url = await client.getAuthorizationUrl(callbackUrl);
        emit(state.copyWith(state: StudiPassauState.authenticating));
        final params = await FlutterWebAuth2.authenticate(
          url: url,
          callbackUrlScheme: callbackUrlScheme,
          options: const FlutterWebAuth2Options(
            intentFlags: ephemeralIntentFlags,
          ),
        );
        final verifier = Uri.parse(params).queryParameters['oauth_verifier']!;
        await client.retrieveAccessToken(verifier);
        await _storageRepo.writeSecure(
          key: oAuthTokenKey,
          value: client.accessToken,
        );
        await _storageRepo.writeSecure(
          key: oAuthSecretKey,
          value: client.accessTokenSecret,
        );
        _setApiClient(client);
        userData = await client.apiGetJson('user');
        fetched = true;
      }
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
