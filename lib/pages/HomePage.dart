import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_instagram/pages/ProfilePage.dart';
import 'package:my_instagram/pages/SearchPage.dart';
import 'package:my_instagram/pages/TimeLinePage.dart';
import 'package:my_instagram/pages/UploadPage.dart';
import 'package:my_instagram/providers/google_sign_in_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController pageController;
  AuthProvider _auth;
  int getPageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  whenPageChanges(int pageIndex) {
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  onTapChangePage(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 400),
      curve: Curves.bounceInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _homePageUI(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapChangePage,
        backgroundColor: Theme.of(context).accentColor,
        activeColor: Colors.blue,
        inactiveColor: Colors.white,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera, size: 37)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),
        ],
      ),
    );
  }

  Widget _homePageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        //  DocumentSnapshot documentSnapshot = us;
        print("user home ${_auth.user}");
        return PageView(
          children: <Widget>[
            TimeLinePage(),
            SearchPage(),
            UploadPage(),
            TimeLinePage(),
            ProfilePage(
              userProfileID: _auth.user.uid,
            ),
          ],
          controller: pageController,
          onPageChanged: whenPageChanges,
          physics: NeverScrollableScrollPhysics(),
        );
      },
    );
  }
}
