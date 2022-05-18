import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studipassau/bloc/cubits/login_cubit.dart';
import 'package:studipassau/bloc/states.dart';
import 'package:studipassau/generated/l10n.dart';
import 'package:studipassau/pages/schedule/schedule.dart';
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
    login(context);
  }

  @override
  Widget build(BuildContext context) => BlocListener<LoginCubit, BlocState>(
        listener: (context, state) {
          if (state.state == StudiPassauState.authenticated) {
            navigateTo(context, routeSchedule);
            navigateTo(context, targetRoute);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).loginTitle),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                BlocBuilder<LoginCubit, BlocState>(
                  builder: getIndicator,
                ),
              ],
            ),
          ),
        ),
      );

  Widget getIndicator(BuildContext context, BlocState state) {
    switch (state.state) {
      case StudiPassauState.notAuthenticated:
        return Text(
          S.of(context).loginNotAuthenticated,
          textAlign: TextAlign.center,
        );
      case StudiPassauState.authenticated:
      case StudiPassauState.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case StudiPassauState.authenticating:
        return Text(
          S.of(context).loginAuthenticating,
          textAlign: TextAlign.center,
        );
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
        onPressed: () => login(context),
        child: Text(S.of(context).loginTryAgain.toUpperCase()),
      );

  void login(BuildContext context) {
    context.read<LoginCubit>().authenticate();
  }
}
