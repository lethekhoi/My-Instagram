import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_instagram/models/comment.dart';
import 'package:my_instagram/models/post.dart';
import 'package:my_instagram/providers/google_sign_in_provider.dart';
import 'package:my_instagram/services/db_service.dart';
import 'package:provider/provider.dart';

import 'package:timeago/timeago.dart' as timeago;

class CommentsPage extends StatefulWidget {
  final Post post;

  CommentsPage({this.post});

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  double _deviceHeight;
  double _deviceWidth;
  ScrollController _listViewController;
  GlobalKey<FormState> _formKey;
  AuthProvider _auth;
  String _messageText;
  _CommentsPageState() {
    _formKey = GlobalKey<FormState>();
    _messageText = "";
    _listViewController = new ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        title: Text(
          "Comments",
          style: TextStyle(fontSize: 17),
        ),
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationPageUI(),
      ),
    );
  }

  Widget _conversationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _messageListView(),
              _commentField(_context),
            ],
          ),
        );
      },
    );
  }

  Widget _messageListView() {
    return Flexible(
      child: StreamBuilder<List<Comment>>(
        stream: DBService.instance.getAllComment(this.widget.post.posID),
        builder: (BuildContext _context, _snapshot) {
          var _commentData = _snapshot.data;
          if (_snapshot.hasData) {
            if (_commentData.length != 0) {
              return ListView.builder(
                controller: _listViewController,
                itemCount: _commentData.length,
                itemBuilder: (BuildContext _context, int _index) {
                  return Container(
                    color: Colors.black,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: RichText(
                              text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: _commentData[_index].username + " ",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(text: _commentData[_index].comment)
                            ],
                          )),
                          leading: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: CircleAvatar(
                              radius: 15,
                              backgroundImage:
                                  NetworkImage(_commentData[_index].url),
                            ),
                          ),
                          subtitle: Text(
                            timeago.format(
                                _commentData[_index].timestamp.toDate()),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Container(
                height: 0,
                width: 0,
              );
            }
          } else {
            return Container(
              height: 0,
              width: 0,
            );
          }
        },
      ),
    );
  }

  Widget _commentField(BuildContext _context) {
    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
      height: _deviceHeight * 0.08,
      width: _deviceWidth,
      decoration: BoxDecoration(
        color: Color.fromRGBO(43, 43, 43, 1),
      ),
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState.save();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _imageUserPost(),
            _commentTextField(),
            _postComment(_context),
          ],
        ),
      ),
    );
  }

  Widget _imageUserPost() {
    return CircleAvatar(
      radius: 15,
      backgroundImage: NetworkImage(_auth.user.photoUrl),
    );
  }

  Widget _commentTextField() {
    return SizedBox(
      width: _deviceWidth * 0.6,
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        validator: (_input) {
          if (_input.length == 0) {
            return "Add a comment...";
          }
          return null;
        },
        onSaved: (_input) {
          setState(() {
            _messageText = _input;
          });
        },
        cursorColor: Colors.white,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Add a comment...",
            hintStyle: TextStyle(color: Colors.white)),
        autocorrect: false,
      ),
    );
  }

  Widget _postComment(BuildContext _context) {
    return GestureDetector(
      child: Text(
        "Post",
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
      onTap: () async {
        if (_formKey.currentState.validate()) {
          await saveComment();
          _formKey.currentState.reset();
          FocusScope.of(_context).unfocus();
        }
      },
    );
  }

  saveComment() async {
    var commentUser = await DBService.instance.getUserInfo(_auth.user.uid);
    await DBService.instance
        .saveComment(this.widget.post.posID, commentUser, _messageText);

    if (_auth.user.uid != this.widget.post.ownerID) {
      await DBService.instance
          .addComment(this.widget.post, _messageText, commentUser);
    }
  }
}
