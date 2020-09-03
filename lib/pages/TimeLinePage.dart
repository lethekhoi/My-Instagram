import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_instagram/models/post.dart';
import 'package:my_instagram/providers/google_sign_in_provider.dart';
import 'package:my_instagram/widgets/HeaderWidget.dart';
import 'package:my_instagram/widgets/PostWidget.dart';
import 'package:my_instagram/widgets/ProgressWidget.dart';
import 'package:provider/provider.dart';

class TimeLinePage extends StatefulWidget {
  final String currentUserID;

  const TimeLinePage({Key key, this.currentUserID}) : super(key: key);
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  List<Post> posts;
  List<String> followingsList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AuthProvider _auth;

  retrieveTimeLine() async {
    followingsList.forEach((element) {});
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection("timeline")
        .document(widget.currentUserID)
        .collection("timelinePosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();

    List<Post> allPosts = querySnapshot.documents
        .map((document) => Post.fromDocument(document))
        .toList();

    setState(() {
      this.posts = allPosts;
    });
  }

  retrieveFollowings() async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection("followers")
        .document(this.widget.currentUserID)
        .collection("userFollowing")
        .getDocuments();
    setState(() {
      followingsList = querySnapshot.documents
          .map((document) => document.documentID)
          .toList();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveFollowings();
    retrieveTimeLine();

    print(":::");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, isAppTitle: true, disableBackbutton: true),
      body: Container(
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: _timelinePageUI(),
        ),
      ),
    );
  }

  Widget _timelinePageUI() {
    return Builder(builder: (BuildContext _context) {
      _auth = Provider.of<AuthProvider>(_context);
      return RefreshIndicator(
          child: createUserTimeLine(), onRefresh: () => retrieveTimeLine());
    });
  }

  createUserTimeLine() {
    if (posts == null) {
      return circularProgress();
    } else {
      return ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: PostWidget(posts[index].ownerID, posts[index]),
          );
        },
      );
    }
  }
}
