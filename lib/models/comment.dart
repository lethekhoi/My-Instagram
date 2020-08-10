import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String username;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;

  Comment({this.username, this.userId, this.url, this.comment, this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot documentSnapshot) {
    return Comment(
      username: documentSnapshot["username"],
      userId: documentSnapshot["userID"],
      url: documentSnapshot["url"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
    );
  }
}
