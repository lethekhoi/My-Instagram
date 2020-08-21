import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_instagram/models/post.dart';
import 'package:my_instagram/models/user.dart';
import 'package:my_instagram/pages/EditProfilePage.dart';
import 'package:my_instagram/providers/google_sign_in_provider.dart';
import 'package:my_instagram/services/db_service.dart';
import 'package:my_instagram/services/navigation_service.dart';
import 'package:my_instagram/widgets/HeaderWidget.dart';
import 'package:my_instagram/widgets/PostTileWidget.dart';
import 'package:my_instagram/widgets/PostWidget.dart';
import 'package:my_instagram/widgets/ProgressWidget.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final String currentUserID;
  final String userProfileID;

  const ProfilePage({Key key, this.userProfileID, this.currentUserID})
      : super(key: key); // user id ghé thăm. có thể là của chính mình

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthProvider _auth;
  String postOrientation = "grid";
  bool following = false;
  int countTotalFollowers = 0;
  int countTotalFollowings = 0;
  int countTotalPost = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPostCount();
    getAllFollowers();
    getAllFollowings();
    checkIfAlreadyFollowing();
  }

  getPostCount() async {
    int count =
        await DBService.instance.getUserPostCount(this.widget.userProfileID);
    if (this.mounted) {
      setState(() {
        countTotalPost = count;
      });
    }
  }

  getAllFollowings() async {
    QuerySnapshot querySnapshot =
        await DBService.instance.getAllFollowings(this.widget.userProfileID);
    if (this.mounted) {
      setState(() {
        countTotalFollowings = querySnapshot.documents.length;
      });
    }
  }

  checkIfAlreadyFollowing() async {
    DocumentSnapshot documentSnapshot = await DBService.instance
        .checkIfAlreadyFollowing(
            this.widget.currentUserID, this.widget.userProfileID);
    if (this.mounted) {
      setState(() {
        following = documentSnapshot.exists;
        print("@@");
      });
    }
  }

  getAllFollowers() async {
    QuerySnapshot querySnapshot =
        await DBService.instance.getAllFollowers(this.widget.userProfileID);
    if (this.mounted) {
      setState(() {
        countTotalFollowers = querySnapshot.documents.length;
      });
    }
  }

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
        shrinkWrap: true,
        children: <Widget>[
          _createProfileTopView(),
          Divider(),
          createListAndGridPostOrientation(),
          Divider(),
          displayProfilePost(),
        ],
      );
    });
  }

  Widget _createProfileTopView() {
    return FutureBuilder<User>(
      future: DBService.instance.getUserInfo(this.widget.userProfileID),
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
                                  createColumns("Posts", countTotalPost),
                                  createColumns(
                                      "Followers", countTotalFollowers),
                                  createColumns(
                                      "Following", countTotalFollowings),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 15),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _userData.profileName,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 15),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _userData.bio,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: createButton(),
                    ),
                  ],
                ),
              )
            : circularProgress();
      },
    );
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
      if (following) {
        return createButtonAndFunction(
            title: "Unfollow", performFunction: unfollowUser);
      } else {
        return createButtonAndFunction(
            title: "Follow", performFunction: followUser);
      }
    }
  }

  createButtonAndFunction({String title, Function performFunction}) {
    Color color = title == "Follow" ? Colors.blue : Colors.black;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: color,
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
          return EditProfilePage(userProfileID: _auth.user.uid);
        },
      ),
    );
  }

  followUser() async {
    setState(() {
      following = true;
    });
    var currentUser = await DBService.instance.getUserInfo(_auth.user.uid);
    await DBService.instance
        .addFollower(_auth.user.uid, this.widget.userProfileID, currentUser);
    getAllFollowers();
  }

  unfollowUser() async {
    setState(() {
      following = false;
    });
    await DBService.instance
        .removeFollower(_auth.user.uid, this.widget.userProfileID);
    getAllFollowers();
  }

  Widget createListAndGridPostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postOrientation == "grid"
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        IconButton(
          onPressed: () => setOrientation("list"),
          icon: Icon(Icons.list, size: 30),
          color: postOrientation == "list"
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
      ],
    );
  }

  setOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }

  Widget displayProfilePost() {
    return StreamBuilder<Object>(
      stream: DBService.instance.getUserPost(this.widget.userProfileID),
      builder: (context, snapshot) {
        List<Post> listPost = snapshot.data;

        if (!snapshot.hasData) {
          return circularProgress();
        } else {
          if (listPost.length > 0) {
            if (postOrientation == "grid") {
              List<GridTile> gridTilesList = [];
              listPost.forEach((eachPost) {
                gridTilesList.add(GridTile(child: PostTile(eachPost)));
              });
              return GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                mainAxisSpacing: 1.5,
                crossAxisSpacing: 1.5,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: gridTilesList,
              );
            } else {
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: listPost.length,
                itemBuilder: (context, index) {
                  return PostWidget(
                    this.widget.userProfileID,
                    listPost[index],
                  );
                },
              );
            }
          } else {
            return Container(
              alignment: Alignment.center,
              height: 50,
              width: 50,
              child: Text(
                "No post yet",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        }
      },
    );
  }

  int getTotalNumberOfLikes(likes) {
    if (likes == null) {
      return 0;
    }

    int counter = 0;
    likes.values.forEach((eachValue) {
      if (eachValue == true) {
        counter = counter + 1;
      }
    });
    return counter;
  }
}
