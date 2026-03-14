import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studipassau/bloc/cubits/login_cubit.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/constants.dart';
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
          state.me != null) {
        navigateTo(context, targetRoute);
      }
    },
    child: Scaffold(
      appBar: AppBar(title: Text(context.i18n.loginTitle)),
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
          context.i18n.loginNotAuthenticated,
          textAlign: TextAlign.center,
        );
      case StudiPassauState.httpError:
      case StudiPassauState.authenticated:
        return state.me == null
            ? RetryScreen.withButton(
                text: context.i18n.httpError,
                button: retryButton(context),
              )
            : const Center(child: CircularProgressIndicator());
      case StudiPassauState.loading:
      case StudiPassauState.authenticating:
        return Text(
          state.me == null
              ? context.i18n.loginAuthenticatingFirst
              : context.i18n.loginAuthenticating,
          textAlign: TextAlign.center,
        );
      default:
        return RetryScreen.withButton(
          text: context.i18n.loginError,
          button: retryButton(context),
        );
    }
  }

  Widget retryButton(BuildContext context) => Column(
    children: [
      RetryButton(
        buttonText: context.i18n.loginTryAgain.toUpperCase(),
        buttonAction: (context) async => login(context),
      ),
      RetryButton(
        buttonText: context.i18n.continueWithoutLogin.toUpperCase(),
        buttonAction: (context) async => navigateTo(context, targetRoute),
      ),
    ],
  );

  Future<void> login(BuildContext context) async {
    await context.read<LoginCubit>().authenticate();
  }
}
