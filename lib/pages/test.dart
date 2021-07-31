import 'package:flutter/material.dart';
import 'package:studipassau/bloc/repo.dart';

class TestPage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TestPage> {
  final StudiPassauRepo _repo = StudiPassauRepo();

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
              _repo.userData['username'].toString(),
              style: Theme.of(context).textTheme.headline4,
            ),
            Image.network(
              _repo.userData['avatar_original'].toString(),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print('lelsdd'),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
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
