import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:studip/studip.dart' as studip;

class LoginPage extends StatelessWidget {
  const LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    //tryLogin(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              // TODO(HyperSpeeed): Change text
              'If no browser opens, install one',
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => tryLogin(context),
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

  void tryLogin(BuildContext context) {
    final client = studip.StudIPClient(
        'https://studip.uni-passau.de/studip/dispatch.php/api',
        DotEnv().env['CONSUMER_KEY'],
        DotEnv().env['CONSUMER_SECRET'],
        apiBaseUrl: 'https://studip.uni-passau.de/studip/api.php/');
    client.getAuthorizationUrl('studipassau://oauth_callback').then((url) {
      return FlutterWebAuth.authenticate(
          url: url, callbackUrlScheme: 'studipassau', saveHistory: false);
    }).then((res) {
      final verifier = Uri.parse(res).queryParameters['oauth_verifier'];
      return client.retrieveAccessToken(verifier);
    }).then((v) {
      return client.apiGetJson('user');
    }).then((decoded) {
      print(decoded['name']['formatted']);
    });
  }
}
