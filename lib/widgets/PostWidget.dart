import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_instagram/models/post.dart';
import 'package:my_instagram/models/user.dart';
import 'package:my_instagram/pages/CommentsPage.dart';
import 'package:my_instagram/pages/ProfilePage.dart';
import 'package:my_instagram/providers/google_sign_in_provider.dart';
import 'package:my_instagram/services/db_service.dart';
import 'package:my_instagram/services/navigation_service.dart';
import 'package:my_instagram/widgets/ProgressWidget.dart';
import 'package:provider/provider.dart';

class PostWidget extends StatefulWidget {
  final profileID;
  final Post post;

  PostWidget(this.profileID, this.post);
  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  AuthProvider _auth;
  bool isLiked = false;
  bool showHeart = false;
  Map listLike;
  int numberOfLike;

  @override
  void initState() {
    super.initState();
    listLike = this.widget.post.likes;
    numberOfLike = getTotalNumberOfLikes(listLike);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: AuthProvider.instance,
      child: postWidgetUI(),
    );
  }

  Widget postWidgetUI() {
    return Builder(
      builder: (BuildContext context) {
        _auth = Provider.of<AuthProvider>(context);
        isLiked =
            listLike[_auth.user.uid] == null ? false : listLike[_auth.user.uid];
        return Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              createPostHead(),
              createPostPicture(),
              createPostFooter()
            ],
          ),
        );
      },
    );
  }

  Widget createPostHead() {
    return FutureBuilder<User>(
      future: DBService.instance.getUserInfo(this.widget.profileID),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        var _userData = dataSnapshot.data;
        bool isPostOwner = this.widget.profileID == _auth.user.uid;
        return ListTile(
          leading: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(_userData.url),
              backgroundColor: Colors.blueAccent,
            ),
          ),
          title: GestureDetector(
            onTap: () => showProfile(this.widget.profileID),
            child: Text(
              _userData.username,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          subtitle: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(children: [
              TextSpan(
                  text: this.widget.post.location,
                  style: TextStyle(fontSize: 12)),
            ]),
          ),
          trailing: isPostOwner
              ? IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    controlPostDelete(context, this.widget.post.posID);
                  },
                )
              : Text(""),
        );
      },
    );
  }

  Widget createPostPicture() {
    return GestureDetector(
      onDoubleTap: () {
        controlUserLikePost();
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(this.widget.post.url),
            ),
          ),
          showHeart
              ? Icon(
                  Icons.favorite,
                  size: 80.0,
                  color: Colors.red,
                )
              : Text(""),
        ],
      ),
    );
  }

  Widget createPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40, left: 15),
            ),
            GestureDetector(
              onTap: () {
                controlUserLikePost();
              },
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28,
                color: Colors.red,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 10)),
            GestureDetector(
              onTap: () {
                displayComments(context, this.widget.post);
              },
              child: Icon(
                Icons.chat_bubble_outline,
                size: 28.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 15.0),
              child: Text(
                numberOfLike == 0 ? "" : "$numberOfLike likes",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                this.widget.post.description == ""
                    ? ""
                    : "${this.widget.post.username}",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                " " + "${this.widget.post.description}",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  displayComments(BuildContext context, Post _post) {
    NavigationService.instance.navigateToRoute(
      MaterialPageRoute(
        builder: (context) {
          return CommentsPage(post: _post);
        },
      ),
    );
  }

  controlUserLikePost() {
    bool _liked = this.widget.post.likes[_auth.user.uid] == true;
    if (_liked) {
      //nếu đã thích thì xóa thích đi
      print("xóa thích");
      DBService.instance.updatePostLike(_auth.user.uid,
          this.widget.post.ownerID, this.widget.post.posID, false);
      removeLike();
      setState(() {
        listLike[_auth.user.uid] = false;
        numberOfLike = getTotalNumberOfLikes(listLike);
      });
    } else {
      //nếu chưa thích thì thêm thích vào
      DBService.instance.updatePostLike(_auth.user.uid,
          this.widget.post.ownerID, this.widget.post.posID, true);
      addLike();
      setState(() {
        listLike[_auth.user.uid] = true;
        numberOfLike = getTotalNumberOfLikes(listLike);
        showHeart = true;
      });
      Timer(Duration(milliseconds: 800), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addLike() async {
    bool isNotPostOwner = this.widget.profileID != _auth.user.uid;
    if (isNotPostOwner) {
      User currentUser = await DBService.instance.getUserInfo(_auth.user.uid);
      await DBService.instance.addLike(this.widget.profileID,
          this.widget.post.posID, currentUser, this.widget.post.url);
    }
  }

  removeLike() async {
    bool isNotPostOwner = this.widget.profileID != _auth.user.uid;

    if (isNotPostOwner) {
      await DBService.instance
          .removeLike(this.widget.profileID, this.widget.profileID);
    }
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

  showProfile(String profileID) {
    NavigationService.instance.navigateToRoute(
      MaterialPageRoute(
        builder: (BuildContext _context) {
          return ProfilePage(
              currentUserID: _auth.user.uid, userProfileID: profileID);
        },
      ),
    );
  }

  controlPostDelete(BuildContext _context, String posID) {
    return showDialog(
        context: _context,
        builder: (_context) {
          return SimpleDialog(
            backgroundColor: new Color.fromRGBO(38, 38, 38, 1),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () async {
                  NavigationService.instance.goBack();
                  NavigationService.instance.goBack();
                  await DBService.instance.removePost(_auth.user.uid, posID);
                  await DBService.instance
                      .removePostComment(_auth.user.uid, posID);
                },
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () {
                  NavigationService.instance.goBack();
                },
              ),
            ],
          );
        });
  }
}
