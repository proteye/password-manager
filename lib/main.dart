import 'package:flutter/material.dart';

import 'package:password_manager/src/routing.dart';
import 'package:password_manager/src/utils/db.util.dart';

DbHelper dbHelper = new DbHelper();

void main() => runApp(App());

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  void init() async {
    // await dbHelper.deleteDb();
    await dbHelper.database;
  }

  @override
  StatelessElement createElement() {
    this.init();
    return StatelessElement(this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: Routing.routes(),
    );
  }
}
