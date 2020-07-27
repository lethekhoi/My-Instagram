import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_instagram/pages/CreateAccountPage.dart';

import 'package:my_instagram/services/db_service.dart';
import 'package:my_instagram/services/navigation_service.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error,
}

class AuthProvider extends ChangeNotifier {
  static AuthProvider instance = AuthProvider();
  FirebaseUser user;
  AuthStatus status;
  GoogleSignIn _googleSignIn;
  FirebaseAuth _auth;

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    _googleSignIn = new GoogleSignIn();
    _checkCurrentUserIsAuthenticated();
  }

  void _autoLogin() async {
    if (user != null) {
      bool isUserCreated = await DBService.instance.checkUserHaveData(user.uid);
      if (!isUserCreated) {
        NavigationService.instance.navigateToRoute(
          MaterialPageRoute(
            builder: (BuildContext _context) {
              return CreateAccountPage();
            },
          ),
        );
      } else {
        NavigationService.instance.navigateToReplacement("home");
      }
    }
  }

  void _checkCurrentUserIsAuthenticated() async {
    user = await _auth.currentUser();
    if (user != null) {
      notifyListeners();
      _autoLogin();
    }
  }

  void loginGoogle() async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      GoogleSignInAccount account = await _googleSignIn.signIn();
      if (account == null) return user = null;
      AuthResult res =
          await _auth.signInWithCredential(GoogleAuthProvider.getCredential(
        idToken: (await account.authentication).idToken,
        accessToken: (await account.authentication).accessToken,
      ));
      if (res.user != null) {
        user = res.user;
        status = AuthStatus.Authenticated;
        bool isUserCreated =
            await DBService.instance.checkUserHaveData(user.uid);

        if (!isUserCreated) {
          NavigationService.instance.navigateToRoute(
            MaterialPageRoute(
              builder: (BuildContext _context) {
                return CreateAccountPage();
              },
            ),
          );
        } else {
          NavigationService.instance.navigateToReplacement("home");
        }
      }
    } catch (e) {
      print(e);
      print("Error logging with google");
      return null;
    }
    notifyListeners();
  }

  void logout() async {
    try {
      await _googleSignIn.signOut();
      user = null;
      status = AuthStatus.NotAuthenticated;
      NavigationService.instance.navigateToReplacement("login");
    } catch (e) {}
  }
}
