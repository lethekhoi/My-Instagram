import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_instagram/models/comment.dart';
import 'package:my_instagram/models/post.dart';
import 'package:my_instagram/models/user.dart';

class DBService {
  static DBService instance = DBService();
  Firestore _db;
  DBService() {
    _db = Firestore.instance;
  }

  String _userCollection = "Users";
  String _userPost = "usersPosts";
  String _commentCollection = "comments";
  String _followersCollection = "followers";

  Future<void> createUserInDB(String _uid, String _profileName,
      String _username, String _url, String _email) async {
    try {
      return await _db.collection(_userCollection).document(_uid).setData({
        "id": _uid,
        "profileName": _profileName,
        "username": _username,
        "url": _url,
        "email": _email,
        "bio": "",
        "timestamp": DateTime.now(),
      });
    } catch (e) {
      print(e);
    }
  }

  Future<bool> checkUserHaveData(String uid) async {
    DocumentSnapshot documentSnapshot = await Firestore.instance
        .collection(_userCollection)
        .document(uid)
        .get();

    if (documentSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Stream<List<User>> searchUser(String _searchName) {
    var _ref = _db
        .collection(_userCollection)
        .where("profileName", isGreaterThanOrEqualTo: _searchName)
        .where("profileName", isLessThanOrEqualTo: _searchName + 'z')
        .getDocuments();

    return _ref.asStream().map((_snapshot) {
      return _snapshot.documents.map((_doc) {
        return User.fromDocument(_doc);
      }).toList();
    });
  }

  Future<void> savePostInfoToFirestore(
    String _uid,
    var _posID,
    String _username,
    String _url,
    String _location,
    String _description,
  ) async {
    try {
      return await _db
          .collection(_userCollection)
          .document(_uid)
          .collection(_userPost)
          .document(_posID)
          .setData({
        "posID": _posID,
        "ownerID": _uid,
        "timestamp": DateTime.now(),
        "likes": {},
        "username": _username,
        "description": _description,
        "location": _location,
        "url": _url,
      });
    } catch (e) {
      print(e);
    }
  }

  Stream<User> getUserData(String _userID) {
    var _ref = _db.collection(_userCollection).document(_userID);
    return _ref.get().asStream().map((_snapshot) {
      return User.fromDocument(_snapshot);
    });
  }

  Future<User> getUserInfo(String _userID) {
    var _ref = _db.collection(_userCollection).document(_userID);
    return _ref.get().then((_snapshot) {
      return User.fromDocument(_snapshot);
    });
  }

  Future<Post> getPostInfo(String _postOwnerID, String _posID) {
    var _ref = _db
        .collection(_userCollection)
        .document(_postOwnerID)
        .collection(_userPost)
        .document(_posID);
    return _ref.get().then((_snapshot) {
      return Post.fromDocument(_snapshot);
    });
  }

  Future<void> updateUserData(
      String _uid, String _profileName, String _bio) async {
    try {
      return await _db.collection(_userCollection).document(_uid).updateData({
        "profileName": _profileName,
        "bio": _bio,
      }).then((_) {
        print("update image success");
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> updatePostLike(String currentOnlineUserID, String ownerID,
      String posID, bool isLiked) async {
    try {
      return await _db
          .collection(_userCollection)
          .document(ownerID)
          .collection(_userPost)
          .document(posID)
          .updateData({"likes.$currentOnlineUserID": isLiked});
    } catch (e) {
      print(e);
    }
  }

  // Future<void> updateUserLastSeen(String _uid) async {
  //   try {
  //     return await _db
  //         .collection(_userCollection)
  //         .document(_uid)
  //         .updateData({"lastSeen": Timestamp.now()}).then((_) {
  //       print("update last seen success");
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Stream<List<Post>> getUserPost(String _userID) {
    var _ref = _db
        .collection(_userCollection)
        .document(_userID)
        .collection(_userPost)
        .orderBy("timestamp", descending: true);
    return _ref.snapshots().map((_snapshot) {
      return _snapshot.documents.map((_doc) {
        return Post.fromDocument(_doc);
      }).toList();
    });
  }

//get user post
  Future<int> getUserPostCount(String _userID) async {
    QuerySnapshot querySnapshot = await _db
        .collection(_userCollection)
        .document(_userID)
        .collection(_userPost)
        .orderBy("timestamp", descending: true)
        .getDocuments();
    return querySnapshot.documents.length;
  }

  //ADD LIKE

  Future<void> addLike(
      String ownerID, String posID, User currentUser, String postURL) async {
    try {
      return await _db
          .collection("feed")
          .document(ownerID)
          .collection("feedItems")
          .document(posID)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "timestamp": DateTime.now(),
        "url": postURL,
        "postId": posID,
        "userProfileImg": currentUser.url,
      });
    } catch (e) {
      print(e);
    }
  }

  //REMOVE LIKE

  Future<void> removeLike(String ownerID, String posID) async {
    try {
      return await _db
          .collection("feed")
          .document(ownerID)
          .collection("feedItems")
          .document(posID)
          .get()
          .then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Stream<List<Comment>> getAllComment(String _posID) {
    var _ref = _db
        .collection(_commentCollection)
        .document(_posID)
        .collection(_commentCollection)
        .orderBy("timestamp", descending: true);
    return _ref.snapshots().map((_snapshot) {
      return _snapshot.documents.map((_doc) {
        return Comment.fromDocument(_doc);
      }).toList();
    });
  }

  Future<void> saveComment(
      String _posID, User userComment, String comment) async {
    try {
      return await _db
          .collection(_commentCollection)
          .document(_posID)
          .collection(_commentCollection)
          .add({
        "username": userComment.username,
        "comment": comment,
        "timestamp": DateTime.now(),
        "url": userComment.url,
        "userID": userComment.id,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> addComment(Post post, String comment, User commentUser) async {
    try {
      return await _db
          .collection("feed")
          .document(post.ownerID)
          .collection("feedItems")
          .add({
        "type": "comment",
        "commentData": comment,
        "postID": post.posID,
        "userID": commentUser.id,
        "username": commentUser.username,
        "userProfileImg": commentUser.url,
        "url": post.url,
        "timestamp": DateTime.now(),
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> removeFollower(String currentUserID, String visitUserID) async {
    try {
      await _db
          .collection(_followersCollection)
          .document(visitUserID)
          .collection("userFollowers")
          .document(currentUserID)
          .get()
          .then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });
      await _db
          .collection(_followersCollection)
          .document(currentUserID)
          .collection("userFollowing")
          .document(visitUserID)
          .get()
          .then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });

      await _db
          .collection("feed")
          .document(visitUserID)
          .collection("feedItems")
          .document(currentUserID)
          .get()
          .then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> addFollower(
      String currentUserID, String visitUserID, User currentUser) async {
    try {
      await _db
          .collection(_followersCollection)
          .document(visitUserID)
          .collection("userFollowers")
          .document(currentUserID)
          .setData({});
      await _db
          .collection(_followersCollection)
          .document(currentUserID)
          .collection("userFollowing")
          .document(visitUserID)
          .setData({});

      await _db
          .collection("feed")
          .document(visitUserID)
          .collection("feedItems")
          .document(currentUserID)
          .setData({
        "type": "follow",
        "ownerId": visitUserID,
        "username": currentUser.username,
        "timestamp": DateTime.now(),
        "userProfileImg": currentUser.url,
        "userId": currentUserID,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<QuerySnapshot> getAllFollowers(String visitUserID) async {
    return await _db
        .collection(_followersCollection)
        .document(visitUserID)
        .collection("userFollowers")
        .getDocuments();
  }

  Future<QuerySnapshot> getAllFollowings(String visitUserID) async {
    return await _db
        .collection(_followersCollection)
        .document(visitUserID)
        .collection("userFollowing")
        .getDocuments();
  }

  Future<DocumentSnapshot> checkIfAlreadyFollowing(
      String currentUserID, String visitUserID) async {
    return await _db
        .collection(_followersCollection)
        .document(visitUserID)
        .collection("userFollowers")
        .document(currentUserID)
        .get();
  }
}
