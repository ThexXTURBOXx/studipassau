import 'package:flutter/material.dart';
import 'package:studipassau/bloc/blocs/oauth_bloc.dart';
import 'package:studipassau/bloc/events/oauth_event.dart';
import 'package:studipassau/bloc/repository/oauth_repo.dart';
import 'package:studipassau/bloc/states/oauth_state.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/util/navigation.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static final OAuthRepo repo = OAuthRepo();
  final OAuthBloc _oAuthBloc = OAuthBloc(repo);

  @override
  void initState() {
    super.initState();
    login();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).loginTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            getIndicator(),
          ],
        ),
      ),
    );
  }

  Widget getIndicator() {
    final state = _oAuthBloc.state;
    if (state is NotAuthenticated) {
      return Text(
        S.of(context).loginNotAuthenticated,
        textAlign: TextAlign.center,
      );
    } else if (state is Loading) {
      return Text(
        S.of(context).loginLoading,
        textAlign: TextAlign.center,
      );
    } else if (state is Authenticating) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is Authenticated) {
      return Text(S.of(context).loginAuthenticated);
    } else {
      return MaterialButton(
        onPressed: () => login(),
        child: Text(S.of(context).loginTryAgain.toUpperCase()),
      );
    }
  }

  void login() {
    _oAuthBloc.add(Authenticate());
    _oAuthBloc.stream.listen((event) {
      if (event is Authenticated) {
        navigateTo(context, '/schedule');
      } else {
        setState(() {});
      }
    });
  }
}
