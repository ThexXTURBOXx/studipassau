import 'package:StudiPassau/bloc/repository/oauth_repo.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TestPage> {
  final OAuthRepo repo = OAuthRepo();

  @override
  Widget build(BuildContext context) {
    //tryLogin(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudiPassau Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              repo.userData['username'].toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Image.network(
              repo.userData['avatar_original'].toString(),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print('lelsdd'),
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
}
