import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_instagram/models/user.dart';
import 'package:my_instagram/pages/ProfilePage.dart';
import 'package:my_instagram/providers/google_sign_in_provider.dart';
import 'package:my_instagram/services/db_service.dart';
import 'package:my_instagram/services/navigation_service.dart';
import 'package:my_instagram/widgets/HeaderWidget.dart';
import 'package:my_instagram/widgets/ProgressWidget.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  AuthProvider _auth;
  String _searchText;
  TextEditingController searchTextEditingController = TextEditingController();

  @override
  initState() {
    super.initState();
    searchTextEditingController.clear();
    _searchText = '';
  }

  _emptyTheTextFromField() {
    searchTextEditingController.clear();
  }

  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _searchPageHeader(),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _userListView(),
      ),
      // body: _userListView(),
    );
  }

  Widget _searchPageHeader() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      title: TextField(
        controller: searchTextEditingController,
        style: TextStyle(fontSize: 18, color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search here...",
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          prefixIcon: Icon(
            Icons.person_pin,
            color: Colors.white,
            size: 30,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: _emptyTheTextFromField,
          ),
        ),
        onSubmitted: (String _input) {
          setState(() {
            _searchText = _input;
          });
        },
      ),
    );
  }

  Widget _userListView() {
    return Builder(builder: (BuildContext context) {
      _auth = Provider.of<AuthProvider>(context);
      return _searchText.length == 0
          ? _displayNoSearchResultScreen()
          : StreamBuilder<List<User>>(
              stream: DBService.instance.searchUser(_searchText),
              builder: (_context, _snapshot) {
                var _usersData = _snapshot.data;
                if (_usersData != null) {}
                return _snapshot.hasData
                    ? displayUsersFoundScreen(_context, _usersData)
                    : circularProgress();
              });
    });
  }

  Widget _displayNoSearchResultScreen() {
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(
              Icons.group,
              color: Colors.grey,
              size: 100,
            ),
            Text(
              "Search",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget displayUsersFoundScreen(BuildContext _context, List<User> _usersData) {
    return ListView.builder(
      itemCount: _usersData.length,
      itemBuilder: (_context, _index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Colors.blueGrey[900],
          elevation: 20,
          margin:
              EdgeInsetsDirectional.only(top: 5, start: 10, end: 10, bottom: 5),
          child: ListTile(
            onTap: () {
              displayUserProfile(_context,
                  userProfileID: _usersData[_index].id);
            },
            leading: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(_usersData[_index].url),
                ),
              ),
            ),
            title: Text(
              _usersData[_index].profileName,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              _usersData[_index].username,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[],
            ),
          ),
        );
      },
    );
  }

  displayUserProfile(BuildContext context, {String userProfileID}) {
    NavigationService.instance.navigateToRoute(
      MaterialPageRoute(
        builder: (BuildContext _context) {
          return ProfilePage(
            userProfileID: userProfileID,
            currentUserID: _auth.user.uid,
          );
        },
      ),
    );
  }
}
