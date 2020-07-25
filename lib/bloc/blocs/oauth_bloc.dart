import 'package:StudiPassau/bloc/events/oauth_event.dart';
import 'package:StudiPassau/bloc/repository/oauth_repo.dart';
import 'package:StudiPassau/bloc/states/oauth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:studip/studip.dart';

class OAuthBloc extends Bloc<OAuthEvent, OAuthState> {
  final OAuthRepo _repo;

  OAuthBloc(this._repo)
      : assert(_repo != null),
        super(NotAuthenticated());

  @override
  Stream<OAuthState> mapEventToState(OAuthEvent event) async* {
    if (event is Authenticate) {
      yield Authenticating();
      final client = StudIPClient(
          'https://studip.uni-passau.de/studip/dispatch.php/api',
          DotEnv().env['CONSUMER_KEY'],
          DotEnv().env['CONSUMER_SECRET'],
          apiBaseUrl: 'https://studip.uni-passau.de/studip/api.php/');
      final url =
          await client.getAuthorizationUrl('studipassau://oauth_callback');
      final params = await FlutterWebAuth.authenticate(
          url: url, callbackUrlScheme: 'studipassau', saveHistory: false);
      final verifier = Uri.parse(params).queryParameters['oauth_verifier'];
      print(verifier);
      await client.retrieveAccessToken(verifier);
      _repo.userData = await client.apiGetJson('user');
      _repo.apiClient = client;
      yield Authenticated();
    }
  }
}
