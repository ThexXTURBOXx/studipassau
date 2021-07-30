import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:studip/studip.dart';
import 'package:studipassau/bloc/events/oauth_event.dart';
import 'package:studipassau/bloc/repository/oauth_repo.dart';
import 'package:studipassau/bloc/states/oauth_state.dart';

class OAuthBloc extends Bloc<OAuthEvent, OAuthState> {
  final OAuthRepo _repo;

  OAuthBloc(this._repo) : super(NotAuthenticated());

  @override
  Stream<OAuthState> mapEventToState(OAuthEvent event) async* {
    if (event is Authenticate) {
      yield Loading();
      try {
        final tok = await _repo.storage.readAll();
        var authenticated = false;

        if (tok.containsKey('oauth_token') && tok.containsKey('oauth_secret')) {
          // Read tokens from storage
          try {
            final client = StudIPClient(
                'https://studip.uni-passau.de/studip/dispatch.php/api',
                dotenv.env['CONSUMER_KEY']!,
                dotenv.env['CONSUMER_SECRET']!,
                accessToken: tok['oauth_token'],
                accessTokenSecret: tok['oauth_secret'],
                apiBaseUrl: 'https://studip.uni-passau.de/studip/api.php/');
            _repo.userData = await client.apiGetJson('user');
            _repo.apiClient = client;
            authenticated = true;
          } catch (e) {
            // Ignore exception, stop loading keys from storage and try to login
            // normally instead
          }
        }

        if (!authenticated) {
          yield Authenticating();
          await login();
        }
        yield Authenticated();
      } catch (e) {
        yield AuthenticationError();
      }
    }
  }

  Future<void> login() async {
    final client = StudIPClient(
        'https://studip.uni-passau.de/studip/dispatch.php/api',
        dotenv.env['CONSUMER_KEY']!,
        dotenv.env['CONSUMER_SECRET']!,
        apiBaseUrl: 'https://studip.uni-passau.de/studip/api.php/');
    final url =
        await client.getAuthorizationUrl('studipassau://oauth_callback');
    final params = await FlutterWebAuth.authenticate(
      url: url,
      callbackUrlScheme: 'studipassau',
      preferEphemeral: true,
    );
    final verifier = Uri.parse(params).queryParameters['oauth_verifier']!;
    await client.retrieveAccessToken(verifier);
    await _repo.storage.write(key: 'oauth_token', value: client.accessToken);
    await _repo.storage
        .write(key: 'oauth_secret', value: client.accessTokenSecret);
    _repo.userData = await client.apiGetJson('user');
    _repo.apiClient = client;
  }
}
