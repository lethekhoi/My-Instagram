import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class CloudStorageService {
  static CloudStorageService instance = CloudStorageService();

  FirebaseStorage _storage;
  StorageReference _baseRef;

  String _post = "Posts Pictures";
  String _messages = "messages";
  String _images = "images";
  CloudStorageService() {
    _storage = FirebaseStorage.instance;
    _baseRef = _storage.ref();
  }

  Future<StorageTaskSnapshot> uploadUserImage(var posID, File _image) {
    try {
      return _baseRef
          .child(_post)
          .child("post_$posID.jpg")
          .putFile(_image)
          .onComplete;
    } catch (e) {
      print(e);
    }
  }

  Future<StorageTaskSnapshot> uploadMediaMessage(String _uid, File _file) {
    var _timestamp = Timestamp.now();
    var _fileName = basename(_file.path);
    _fileName += "${_timestamp.toString()}";
    try {
      return _baseRef
          .child(_messages)
          .child(_uid)
          .child(_images)
          .child(_fileName)
          .putFile(_file)
          .onComplete;
    } catch (e) {
      print(e);
    }
  }
}
