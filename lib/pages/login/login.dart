import 'package:StudiPassau/bloc/blocs/oauth_bloc.dart';
import 'package:StudiPassau/bloc/events/oauth_event.dart';
import 'package:StudiPassau/bloc/repository/oauth_repo.dart';
import 'package:StudiPassau/bloc/states/oauth_state.dart';
import 'package:StudiPassau/pages/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class LoginPage extends StatefulWidget {
  final OAuthRepo repo = OAuthRepo();

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  OAuthBloc _oAuthBloc;
  AnimationController _fadeController;
  Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _oAuthBloc = OAuthBloc(widget.repo);
    login();
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'login.title')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FadeTransition(
              opacity: _fadeAnimation,
              child: BlocBuilder(
                cubit: _oAuthBloc,
                builder: (context, state) {
                  _fadeController.reset();
                  _fadeController.forward();
                  if (state is NotAuthenticated) {
                    return Text(
                      FlutterI18n.translate(context, 'login.notauth'),
                      textAlign: TextAlign.center,
                    );
                  } else if (state is Authenticating) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is Authenticated) {
                    _fadeController.dispose();
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => TestPage()),
                          (Route<dynamic> route) => false);
                    });
                    return const Text('');
                  } else {
                    return MaterialButton(
                      onPressed: () => login(),
                      child: Text(
                          FlutterI18n.translate(context, 'login.tryagain')
                              .toUpperCase()),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void login() {
    _oAuthBloc.add(Authenticate());
  }
}
