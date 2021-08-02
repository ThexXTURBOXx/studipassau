import 'package:flutter/material.dart';
import 'package:studipassau/bloc/blocs/login_bloc.dart';
import 'package:studipassau/bloc/events.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/util/navigation.dart';

const ROUTE_LOGIN = '/login';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginBloc _loginBloc = LoginBloc();

  @override
  void initState() {
    super.initState();
    _loginBloc.stream.listen((event) {
      if (event == StudiPassauState.AUTHENTICATED) {
        navigateTo(context, '/schedule');
      } else {
        setState(() {});
      }
    });
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
    switch (_loginBloc.state) {
      case StudiPassauState.NOT_AUTHENTICATED:
        return Text(
          S.of(context).loginNotAuthenticated,
          textAlign: TextAlign.center,
        );
      case StudiPassauState.LOADING:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case StudiPassauState.AUTHENTICATING:
        return Text(
          S.of(context).loginAuthenticating,
          textAlign: TextAlign.center,
        );
      case StudiPassauState.AUTHENTICATED:
        return Text(S.of(context).loginAuthenticated);
      default:
        return MaterialButton(
          onPressed: () => login(),
          child: Text(S.of(context).loginTryAgain.toUpperCase()),
        );
    }
  }

  void login() {
    _loginBloc.add(Authenticate());
  }
}
