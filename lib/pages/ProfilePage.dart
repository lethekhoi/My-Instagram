import 'package:flutter/material.dart';
import 'package:my_instagram/models/user.dart';
import 'package:my_instagram/pages/EditProfilePage.dart';
import 'package:my_instagram/providers/google_sign_in_provider.dart';
import 'package:my_instagram/services/db_service.dart';
import 'package:my_instagram/services/navigation_service.dart';
import 'package:my_instagram/widgets/HeaderWidget.dart';
import 'package:my_instagram/widgets/ProgressWidget.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileID;

  const ProfilePage({Key key, this.userProfileID})
      : super(key: key); // user id ghé thăm. có thể là của chính mình

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthProvider _auth;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: "Profile", disableBackbutton: true),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _profilepageUI(),
      ),
    );
  }

  Widget _profilepageUI() {
    return Builder(builder: (BuildContext context) {
      _auth = Provider.of<AuthProvider>(context);
      return ListView(
        children: <Widget>[
          _createProfileTopView(),
        ],
      );
    });
  }

  Widget _createProfileTopView() {
    return StreamBuilder<User>(
        stream: DBService.instance.getUserData(this.widget.userProfileID),
        builder: (context, snapshot) {
          var _userData = snapshot.data;
          return snapshot.hasData
              ? Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.lightBlueAccent,
                              backgroundImage: NetworkImage(_userData.url),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    createColumns("Posts", 0),
                                    createColumns("Followers", 0),
                                    createColumns("Following", 0),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      createButton(),
                    ],
                  ),
                )
              : circularProgress();
        });
  }

  Column createColumns(String title, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget createButton() {
    if (this.widget.userProfileID == _auth.user.uid) {
      return createButtonAndFunction(
          title: "Edit Profile", performFunction: editUserProfile);
    } else {
      return Container(
        height: 50,
        width: 200,
        color: Colors.yellow,
      );
    }
  }

  createButtonAndFunction({String title, Function performFunction}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(6.0),
        ),
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.width * 1,
        child: FlatButton(
          onPressed: performFunction,
          child: Text(
            title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  editUserProfile() {
    NavigationService.instance.navigateToRoute(
      MaterialPageRoute(
        builder: (BuildContext _context) {
          return EditProfilePage();
        },
      ),
    );
  }
}
