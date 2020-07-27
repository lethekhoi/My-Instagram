import 'package:cloud_firestore/cloud_firestore.dart';

class DBService {
  static DBService instance = DBService();
  Firestore _db;
  DBService() {
    _db = Firestore.instance;
  }
  String _userCollection = "Users";
  String _conversationCollection = "Conversations";
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

  // Future<void> updateImage(String _uid, String _imageURL) async {
  //   try {
  //     return await _db
  //         .collection(_userCollection)
  //         .document(_uid)
  //         .updateData({"image": _imageURL}).then((_) {
  //       print("update image success");
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

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

  // Stream<Contact> getUserData(String _userID) {
  //   var _ref = _db.collection(_userCollection).document(_userID);
  //   return _ref.get().asStream().map((_snapshot) {
  //     return Contact.fromFirestore(_snapshot);
  //   });
  // }

  // Stream<List<Conversation>> getUserConversations(String _userID) {
  //   var _ref = _db
  //       .collection(_userCollection)
  //       .document(_userID)
  //       .collection(_conversationCollection);
  //   return _ref.snapshots().map((_snapshot) {
  //     return _snapshot.documents.map((_doc) {
  //       return Conversation.fromFirestore(_doc);
  //     }).toList();
  //   });
  // }

  // Stream<List<Contact>> getUserInDB(String _searchName) {
  //   // 'foo' 'foo' =>'fooz' 'fooa' 'fooq'
  //   var _ref = _db
  //       .collection(_userCollection)
  //       .where("name", isGreaterThanOrEqualTo: _searchName)
  //       .where("name", isLessThanOrEqualTo: _searchName + 'z');
  //   return _ref.getDocuments().asStream().map((_snapshot) {
  //     return _snapshot.documents.map((_doc) {
  //       return Contact.fromFirestore(_doc);
  //     }).toList();
  //   });
  // }

  // Stream<ConversationDetail> getConversation(String _conversationID) {
  //   var _ref =
  //       _db.collection(_conversationCollection).document(_conversationID);
  //   return _ref.snapshots().map(
  //     (_doc) {
  //       return ConversationDetail.fromFirestore(_doc);
  //     },
  //   );
  // }

  // Future<void> sendMessage(String _coversationID, Message _message) {
  //   var _ref = _db.collection(_conversationCollection).document(_coversationID);
  //   var _messageType = "";
  //   switch (_message.type) {
  //     case MessageType.Text:
  //       _messageType = "text";
  //       break;
  //     case MessageType.Image:
  //       _messageType = "image";
  //       break;
  //     default:
  //   }
  //   return _ref.updateData({
  //     "messages": FieldValue.arrayUnion(
  //       [
  //         {
  //           "message": _message.message,
  //           "senderID": _message.senderID,
  //           "timestamp": _message.timestamp,
  //           "type": _messageType,
  //         },
  //       ],
  //     ),
  //   });
  // }

  // Future<void> createOrGetConversation(String _currentID, String _recepientID,
  //     Future<void> _onSuccess(String _conversationID)) async {
  //   var _ref = _db.collection(_conversationCollection);
  //   var _userConversationRef = _db
  //       .collection(_userCollection)
  //       .document(_currentID)
  //       .collection(_conversationCollection);

  //   try {
  //     var conversation =
  //         await _userConversationRef.document(_recepientID).get();
  //     if (conversation.data != null) {
  //       return _onSuccess(conversation.data["conversationID"]);
  //     } else {
  //       var _conversationRef = _ref.document();
  //       await _conversationRef.setData(
  //         {
  //           "members": [_currentID, _recepientID],
  //           "ownerID": _currentID,
  //           "messages": [],
  //         },
  //       );
  //       return _onSuccess(_conversationRef.documentID);
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}
