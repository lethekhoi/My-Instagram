import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    // _checkCurrentUserIsAuthenticated();
  }

  // void _autoLogin() async {
  //   if (user != null) {
  //     await DBService.instance.updateUserLastSeen(user.uid);
  //     return NavigationService.instance.navigateToReplacement("home");
  //   }
  // }

  // void _checkCurrentUserIsAuthenticated() async {
  //   user = await _auth.currentUser();
  //   if (user != null) {
  //     notifyListeners();
  //     _autoLogin();
  //   }
  // }

  // void loginUserWithEmailandPassWord(String _email, String _password) async {
  //   status = AuthStatus.Authenticating;
  //   notifyListeners();
  //   try {
  //     AuthResult _result = await _auth.signInWithEmailAndPassword(
  //         email: _email, password: _password);

  //     user = _result.user;
  //     status = AuthStatus.Authenticated;
  //     SnackBarService.instance.showSnackBarSuccess("Welcome ${user.email}");
  //     //update last seen
  //     await DBService.instance.updateUserLastSeen(user.uid);
  //     print("Login In Successfullys");
  //     //navigation to home page
  //     NavigationService.instance.navigateToReplacement("home");
  //   } catch (e) {
  //     status = AuthStatus.Error;
  //     user = null;
  //     print("Login Error");
  //     SnackBarService.instance.showSnackBarError("Error");
  //     //display an error
  //   }
  //   notifyListeners();
  // }

  // void registerUserWithEmailAndPassword(String _email, String _password,
  //     Future<void> onSuccess(String _uid)) async {
  //   status = AuthStatus.Authenticating;
  //   notifyListeners();
  //   try {
  //     AuthResult _result = await _auth.createUserWithEmailAndPassword(
  //         email: _email, password: _password);
  //     user = _result.user;
  //     status = AuthStatus.Authenticated;

  //     await onSuccess(user.uid);

  //     SnackBarService.instance.showSnackBarSuccess("Welcome ${user.email}");
  //     //Update last seen time
  //     await DBService.instance.updateUserLastSeen(user.uid);
  //     NavigationService.instance.goBack();
  //     //Navigation to HomePage
  //     NavigationService.instance.navigateToReplacement("home");
  //   } catch (e) {
  //     status = AuthStatus.Error;
  //     user = null;
  //     print("Register Error");
  //     SnackBarService.instance.showSnackBarError("Error Registing User");
  //   }
  //   notifyListeners();
  // }

  // void logoutUser(Future<void> onSuccess()) async {
  //   try {
  //     await _auth.signOut();
  //     await _googleSignIn.signOut();
  //     user = null;
  //     status = AuthStatus.NotAuthenticated;
  //     await onSuccess();
  //     await NavigationService.instance.navigateToReplacement("login");
  //     SnackBarService.instance.showSnackBarSuccess("Logged out Successfully");
  //   } catch (e) {
  //     SnackBarService.instance.showSnackBarSuccess("Error Logged out ");
  //   }
  //   notifyListeners();
  // }

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

        NavigationService.instance.navigateToReplacement("home");
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
