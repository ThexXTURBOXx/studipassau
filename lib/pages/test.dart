import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:studip/studip.dart' as studip;

class TestPage extends StatefulWidget {
  const TestPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TestPage> {
  String _name = '';
  String _picture = '';

  void loggedIn(dynamic json) {
    setState(() {
      _name = json['name']['formatted'].toString();
      _picture = json['avatar_original'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    //tryLogin(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _name,
              style: Theme.of(context).textTheme.headline4,
            ),
            Image.network(
              _picture,
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
      loggedIn(decoded);
    });
  }
}
