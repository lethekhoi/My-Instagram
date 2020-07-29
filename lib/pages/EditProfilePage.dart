import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_instagram/providers/google_sign_in_provider.dart';
import 'package:my_instagram/services/db_service.dart';
import 'package:my_instagram/services/navigation_service.dart';
import 'package:my_instagram/widgets/ProgressWidget.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  final String userProfileID;

  const EditProfilePage({Key key, this.userProfileID}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController profileNameTextEditingController =
      TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();

  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  AuthProvider _auth;
  bool loading = false;
  bool _bioValid = true;
  bool _profileNameValid = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAndDisplayUserInfomation();
  }

  getAndDisplayUserInfomation() async {
    setState(() {
      loading = true;
    });
    var userInfo =
        await DBService.instance.getUserInfo(this.widget.userProfileID);
    profileNameTextEditingController.text = userInfo.profileName;
    bioTextEditingController.text = userInfo.bio;
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobalKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.blue,
              ),
              onPressed: () {
                NavigationService.instance.goBack();
              })
        ],
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _editProfilePageUI(),
      ),
    );
  }

  Widget _editProfilePageUI() {
    return Builder(builder: (BuildContext context) {
      _auth = Provider.of<AuthProvider>(context);
      return loading
          ? circularProgress()
          : StreamBuilder(
              stream: DBService.instance.getUserData(_auth.user.uid),
              builder: (context, snapshot) {
                var _userData = snapshot.data;
                return !snapshot.hasData
                    ? circularProgress()
                    : editProfileScreen(_userData);
              });
    });
  }

  Widget editProfileScreen(var _userData) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.lightBlueAccent,
                  backgroundImage: NetworkImage(_userData.url),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  _profileNameTextFormField(),
                  Divider(height: 10),
                  _bioTextFormField(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                color: Colors.green,
                child: Text(
                  "Update",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  updateUserData();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: RaisedButton(
                color: Colors.red,
                child: Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                onPressed: () async {
                  _auth.logout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileNameTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Profile Name",
          style: TextStyle(color: Colors.blue),
        ),
        TextField(
          style: TextStyle(color: Colors.white),
          controller: profileNameTextEditingController,
          decoration: InputDecoration(
            hintText: "Write profile name here ...",
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            errorText: _profileNameValid ? null : "Profile name is short",
          ),
        ),
      ],
    );
  }

  Widget _bioTextFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Bio",
          style: TextStyle(color: Colors.blue),
        ),
        TextField(
          style: TextStyle(color: Colors.white),
          controller: bioTextEditingController,
          decoration: InputDecoration(
            hintText: "Write your bio here ...",
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            errorText: _bioValid ? null : "Bio is very long",
          ),
        ),
      ],
    );
  }

  updateUserData() async {
    setState(() {
      profileNameTextEditingController.text.trim().length < 3 ||
              profileNameTextEditingController.text.isEmpty
          ? _profileNameValid = false
          : _profileNameValid = true;

      bioTextEditingController.text.trim().length > 110 ||
              bioTextEditingController.text.isEmpty
          ? _bioValid = false
          : _bioValid = true;
    });

    if (_bioValid && _profileNameValid) {
      await DBService.instance.updateUserData(_auth.user.uid,
          profileNameTextEditingController.text, bioTextEditingController.text);

      SnackBar successSnackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Profile has been updated successfully",
          style: TextStyle(color: Colors.white),
        ),
      );
      _scaffoldGlobalKey.currentState.showSnackBar(successSnackBar);
    }
  }
}
