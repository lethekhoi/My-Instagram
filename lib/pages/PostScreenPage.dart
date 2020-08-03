import 'package:flutter/material.dart';
import 'package:my_instagram/models/post.dart';
import 'package:my_instagram/providers/google_sign_in_provider.dart';
import 'package:my_instagram/services/db_service.dart';
import 'package:my_instagram/widgets/HeaderWidget.dart';
import 'package:my_instagram/widgets/PostWidget.dart';
import 'package:my_instagram/widgets/ProgressWidget.dart';
import 'package:provider/provider.dart';

class PostScreenPage extends StatefulWidget {
  final Post post;

  PostScreenPage({this.post});

  @override
  _PostScreenPageState createState() => _PostScreenPageState();
}

class _PostScreenPageState extends State<PostScreenPage> {
  AuthProvider _auth;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: ""),
      body: ChangeNotifierProvider<AuthProvider>.value(
          child: _postScreenPageUI(), value: AuthProvider.instance),
    );
  }

  Widget _postScreenPageUI() {
    return Builder(builder: (BuildContext context) {
      _auth = Provider.of<AuthProvider>(context);
      return FutureBuilder<Post>(
          future: DBService.instance
              .getPostInfo(this.widget.post.ownerID, this.widget.post.posID),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            } else {
              Post postdata = snapshot.data;
              print(postdata.posID);
              print(postdata.ownerID);

              return ListView(
                children: <Widget>[
                  PostWidget(
                    postdata.ownerID,
                    postdata,
                  )
                ],
              );
            }
          });
    });
  }
}
