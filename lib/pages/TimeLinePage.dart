import 'package:flutter/material.dart';
import 'package:my_instagram/providers/google_sign_in_provider.dart';
import 'package:my_instagram/widgets/HeaderWidget.dart';
import 'package:provider/provider.dart';

class TimeLinePage extends StatefulWidget {
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  AuthProvider _auth;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: Container(
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: _timelinePageUI(),
        ),
      ),
    );
  }

  Widget _timelinePageUI() {
    return Builder(builder: (BuildContext _context) {
      _auth = Provider.of<AuthProvider>(_context);
      return Container(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () async {
            _auth.logout();
          },
          child: Container(
            color: Colors.red,
            height: 50,
            width: 50,
            child: Text("Log out"),
          ),
        ),
      );
    });
  }
}
