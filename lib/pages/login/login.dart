import 'package:flutter/material.dart';
import 'package:studipassau/bloc/blocs/login_bloc.dart';
import 'package:studipassau/bloc/events.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/util/navigation.dart';

const routeLogin = '/login';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginBloc _loginBloc = LoginBloc();

  @override
  void initState() {
    super.initState();
    _loginBloc.stream.listen((event) {
      if (event == StudiPassauState.authenticated) {
        navigateTo(context, '/schedule');
      } else {
        setState(() {});
      }
    });
    login();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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

  Widget getIndicator() {
    switch (_loginBloc.state) {
      case StudiPassauState.notAuthenticated:
        return Text(
          S.of(context).loginNotAuthenticated,
          textAlign: TextAlign.center,
        );
      case StudiPassauState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case StudiPassauState.authenticating:
        return Text(
          S.of(context).loginAuthenticating,
          textAlign: TextAlign.center,
        );
      case StudiPassauState.authenticated:
        return Text(S.of(context).loginAuthenticated);
      case StudiPassauState.httpError:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                S.of(context).httpError,
                textAlign: TextAlign.center,
              ),
              retryButton(context),
            ],
          ),
        );
      default:
        return retryButton(context);
    }
  }

  Widget retryButton(BuildContext context) => MaterialButton(
        onPressed: login,
        child: Text(S.of(context).loginTryAgain.toUpperCase()),
      );

  void login() {
    _loginBloc.add(Authenticate());
  }
}
