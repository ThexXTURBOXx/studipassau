import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studipassau/bloc/cubits/login_cubit.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/login/widgets/retry_button.dart';
import 'package:studipassau/pages/login/widgets/retry_screen.dart';
import 'package:studipassau/util/navigation.dart';

const routeLogin = '/login';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    unawaited(login(context));
  }

  @override
  Widget build(BuildContext context) => BlocListener<LoginCubit, LoginState>(
    listener: (context, state) {
      if ((state.state == StudiPassauState.authenticated ||
              state.state == StudiPassauState.httpError) &&
          state.userData != null) {
        navigateTo(context, targetRoute);
      }
    },
    child: Scaffold(
      appBar: AppBar(title: Text(S.of(context).loginTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BlocBuilder<LoginCubit, LoginState>(builder: getIndicator),
          ],
        ),
      ),
    ),
  );

  Widget getIndicator(BuildContext context, LoginState state) {
    switch (state.state) {
      case StudiPassauState.notAuthenticated:
        return Text(
          S.of(context).loginNotAuthenticated,
          textAlign: TextAlign.center,
        );
      case StudiPassauState.httpError:
      case StudiPassauState.authenticated:
      case StudiPassauState.loading:
        return state.userData == null
            ? RetryScreen.withButton(
                text: S.of(context).httpError,
                button: retryButton(context),
              )
            : const Center(child: CircularProgressIndicator());
      case StudiPassauState.authenticating:
        return Text(
          S.of(context).loginAuthenticating,
          textAlign: TextAlign.center,
        );
      default:
        return RetryScreen.withButton(
          text: S.of(context).loginError,
          button: retryButton(context),
        );
    }
  }

  Widget retryButton(BuildContext context) => Column(
    children: [
      RetryButton(
        buttonText: S.of(context).loginTryAgain.toUpperCase(),
        buttonAction: (context) async => login(context),
      ),
      RetryButton(
        buttonText: S.of(context).continueWithoutLogin.toUpperCase(),
        buttonAction: (context) async => navigateTo(context, targetRoute),
      ),
    ],
  );

  Future<void> login(BuildContext context) async {
    await context.read<LoginCubit>().authenticate();
  }
}
