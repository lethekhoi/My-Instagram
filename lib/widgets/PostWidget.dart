import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_instagram/models/post.dart';
import 'package:my_instagram/models/user.dart';
import 'package:my_instagram/providers/google_sign_in_provider.dart';
import 'package:my_instagram/services/db_service.dart';
import 'package:my_instagram/widgets/ProgressWidget.dart';
import 'package:provider/provider.dart';

class PostWidget extends StatefulWidget {
  final profileID;
  final Post post;
  final int likeCount;

  PostWidget(this.profileID, this.post, this.likeCount);
  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  AuthProvider _auth;
  bool isLiked = false;
  bool showHeart = false;
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
        return Padding(
          padding: EdgeInsets.only(bottom: 12.0),
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
              radius: 15,
              backgroundImage: NetworkImage(_userData.url),
              backgroundColor: Colors.blueAccent,
            ),
          ),
          title: GestureDetector(
            onTap: () => print("show profile"),
            child: Text(
              _userData.profileName,
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
                    print("delete");
                  },
                )
              : Text(""),
        );
      },
    );
  }

  Widget createPostPicture() {
    return GestureDetector(
      onDoubleTap: () => print("post liked"),
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
            Padding(padding: EdgeInsets.only(top: 40, left: 15)),
            GestureDetector(
              onTap: () => print("like post"),
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28,
                color: Colors.red,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 10)),
            GestureDetector(
              onTap: () => print("comment"),
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
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                this.widget.likeCount == 0
                    ? ""
                    : "${this.widget.likeCount} likes",
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

  displayComments(BuildContext context,
      {String postId, String ownerId, String url}) {
    // Navigator.push(context, MaterialPageRoute(builder: (context)
    //     {
    //       //return CommentsPage(postId: postId, postOwnerId: ownerId, postImageUrl: url);
    //     }
    // ));
  }
}
