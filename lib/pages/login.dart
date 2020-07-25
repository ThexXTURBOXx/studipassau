import 'package:StudiPassau/bloc/blocs/oauth_bloc.dart';
import 'package:StudiPassau/bloc/events/oauth_event.dart';
import 'package:StudiPassau/bloc/repository/oauth_repo.dart';
import 'package:StudiPassau/bloc/states/oauth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  /*

    OAuthRepo.init().then((v) {
      return OAuthRepo.instance.client.apiGetJson('user');
    }).then((decoded) {
      print(decoded['name']['formatted']);
    });
   */

  @override
  Widget build(BuildContext context) {
    //tryLogin(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudiPassau Login'),
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
                    return const Text('Not authenticated.');
                  } else if (state is Authenticating) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is Authenticated) {
                    return Text(widget.repo.userData['user_id'].toString());
                  } else {
                    return const Text('UNDEFINED');
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => login(),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: const Text('Drawer Header'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () => print('hello 1'),
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () => print('hello 2'),
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
