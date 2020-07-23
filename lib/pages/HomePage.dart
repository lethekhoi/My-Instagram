import 'package:flutter/material.dart';
import 'package:my_instagram/providers/google_sign_in_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthProvider _auth;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _homePageUI(),
      ),
    );
  }

  Widget _homePageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return Container(
          color: Colors.red,
          height: 100,
          width: 100,
          child: FlatButton(
            onPressed: () {
              _auth.logout();
            },
            child: Text("Log out"),
          ),
        );
      },
    );
  }
}
