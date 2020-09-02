import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsItem {
  final String username;
  final String type;
  final String commentData;
  final String postID;
  final String userID;
  final String userProfileImg;
  final String url;
  final Timestamp timestamp;

  NotificationsItem(
      {this.username,
      this.type,
      this.commentData,
      this.postID,
      this.userID,
      this.userProfileImg,
      this.url,
      this.timestamp});

  factory NotificationsItem.fromDocument(DocumentSnapshot documentSnapshot) {
    return NotificationsItem(
      username: documentSnapshot["username"],
      type: documentSnapshot["type"],
      commentData: documentSnapshot["commentData"],
      postID: documentSnapshot["postID"],
      userID: documentSnapshot["userID"],
      userProfileImg: documentSnapshot["userProfileImg"],
      url: documentSnapshot["url"],
      timestamp: documentSnapshot["timestamp"],
    );
  }
}
