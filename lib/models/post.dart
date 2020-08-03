import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String posID;
  final String ownerID;
  final Map likes;
  final String username;
  final String description;
  final String location;
  final String url;

  Post({
    this.posID,
    this.ownerID,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
  });

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      posID: documentSnapshot["posID"],
      ownerID: documentSnapshot["ownerID"],
      likes: documentSnapshot["likes"],
      username: documentSnapshot["username"],
      description: documentSnapshot["description"],
      location: documentSnapshot["location"],
      url: documentSnapshot["url"],
    );
  }

  
}
