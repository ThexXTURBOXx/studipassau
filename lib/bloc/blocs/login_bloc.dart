import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/events.dart';
import 'package:studipassau/bloc/repo.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';

class LoginBloc extends Bloc<LoginEvent, StudiPassauState> {
  static final StudiPassauRepo _repo = StudiPassauRepo();

  LoginBloc() : super(StudiPassauState.notAuthenticated) {
    on<Authenticate>(_authenticate);
  }

  Future<void> _authenticate(
    Authenticate event,
    Emitter<StudiPassauState> emit,
  ) async {
    emit(StudiPassauState.loading);
    try {
      final tok = await _repo.storage.readAll();
      var authenticated = false;

      if (tok.containsKey('oauth_token') && tok.containsKey('oauth_secret')) {
        // Read tokens from storage
        try {
          final client = StudIPClient(
            oauthBaseUrl,
            consumerKey,
            consumerSecret,
            accessToken: tok['oauth_token'],
            accessTokenSecret: tok['oauth_secret'],
            apiBaseUrl: apiBaseUrl,
          );
          _repo.userData = await client.apiGetJson('user');
          _repo.apiClient = client;
          authenticated = true;
        } catch (e) {
          // Ignore exception, stop loading keys from storage and try to login
          // normally instead, since the saved token is invalid or a server
          // error occurred. In the second case, just try logging in again
          // as well... Doesn't hurt...
        }
      }

      if (!authenticated) {
        final client = StudIPClient(
          oauthBaseUrl,
          consumerKey,
          consumerSecret,
          apiBaseUrl: apiBaseUrl,
        );
        final url = await client.getAuthorizationUrl(callbackUrl);
        emit(StudiPassauState.authenticating);
        final params = await FlutterWebAuth.authenticate(
          url: url,
          callbackUrlScheme: callbackUrlScheme,
          preferEphemeral: true,
        );
        final verifier = Uri.parse(params).queryParameters['oauth_verifier']!;
        await client.retrieveAccessToken(verifier);
        await _repo.storage
            .write(key: 'oauth_token', value: client.accessToken);
        await _repo.storage
            .write(key: 'oauth_secret', value: client.accessTokenSecret);
        _repo.userData = await client.apiGetJson('user');
        _repo.apiClient = client;
      }
      emit(StudiPassauState.authenticated);
    } catch (e) {
      if (e is StateError || e is SocketException) {
        emit(StudiPassauState.httpError);
      } else {
        emit(StudiPassauState.authenticationError);
      }
    }
  }
}
