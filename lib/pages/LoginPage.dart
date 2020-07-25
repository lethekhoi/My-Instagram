import 'package:flutter/material.dart';
import 'package:my_instagram/providers/google_sign_in_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthProvider _auth;
  @override
  Widget build(BuildContext context) {
    return buildSignInScreen();
  }

  Widget buildSignInScreen() {
    return Scaffold(
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _loginUI(),
      ),
    );
  }

  Widget _loginUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        print("user ${_auth.user}");
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).accentColor,
                Theme.of(context).primaryColor
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text(
                  "Instagram",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 60,
                      fontFamily: "Dancing Script"),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  _auth.loginGoogle();
                },
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  height: 50,
                  width: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            "assets/images/google_signin_button.png"),
                        fit: BoxFit.cover),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
