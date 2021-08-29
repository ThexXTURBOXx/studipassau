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

  LoginBloc() : super(StudiPassauState.NOT_AUTHENTICATED);

  @override
  Stream<StudiPassauState> mapEventToState(LoginEvent event) async* {
    if (event is Authenticate) {
      yield StudiPassauState.LOADING;
      try {
        final tok = await _repo.storage.readAll();
        var authenticated = false;

        if (tok.containsKey('oauth_token') && tok.containsKey('oauth_secret')) {
          // Read tokens from storage
          try {
            final client = StudIPClient(
                OAUTH_BASE_URL, consumerKey, consumerSecret,
                accessToken: tok['oauth_token'],
                accessTokenSecret: tok['oauth_secret'],
                apiBaseUrl: API_BASE_URL);
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
              OAUTH_BASE_URL, consumerKey, consumerSecret,
              apiBaseUrl: API_BASE_URL);
          final url = await client.getAuthorizationUrl(CALLBACK_URL);
          yield StudiPassauState.AUTHENTICATING;
          final params = await FlutterWebAuth.authenticate(
            url: url,
            callbackUrlScheme: CALLBACK_URL_SCHEME,
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
        yield StudiPassauState.AUTHENTICATED;
      } catch (e) {
        print('${e.runtimeType} ddd $e');
        if (e is StateError || e is SocketException) {
          yield StudiPassauState.HTTP_ERROR;
        } else {
          yield StudiPassauState.AUTHENTICATION_ERROR;
        }
      }
    }
  }
}
