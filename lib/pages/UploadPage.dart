import 'dart:io';
import 'package:my_instagram/services/cloud_storage_service.dart';
import 'package:my_instagram/services/db_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_instagram/providers/google_sign_in_provider.dart';
import 'package:my_instagram/services/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as ImD;

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File _file;
  bool uploading = false;
  var posID = new Uuid().v1();

  TextEditingController descriptionTextEditingController =
      TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();
  AuthProvider _auth;
  @override
  Widget build(BuildContext context) {
    return _file == null ? _displayUploadScreen() : _displayUploadFormScreen();
  }

  Widget _displayUploadScreen() {
    print("qqqq : " + posID);
    return Scaffold(
      body: Container(
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: _uploadPageUI(),
        ),
      ),
    );
  }

  Widget _displayUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).accentColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _removeImage,
        ),
        title: Text(
          "New Post",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: uploading
                ? null
                : () {
                    controlUploadAndSave();
                  },
            child: Text(
              "Share",
              style: TextStyle(
                color: Colors.lightGreenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: ListView(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.height * 0.8,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: FileImage(_file),
                      fit: BoxFit.cover,
                    )),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(_auth.user.photoUrl),
                ),
                title: TextField(
                  style: TextStyle(color: Colors.white),
                  controller: descriptionTextEditingController,
                  decoration: InputDecoration(
                      hintText: "Your note",
                      hintStyle: TextStyle(fontSize: 13, color: Colors.white),
                      border: InputBorder.none),
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.person_pin_circle,
                  color: Colors.white,
                  size: 36,
                ),
                title: TextField(
                  style: TextStyle(color: Colors.white, fontSize: 13),
                  controller: locationTextEditingController,
                  decoration: InputDecoration(
                      hintText: "Your Location",
                      hintStyle: TextStyle(fontSize: 13, color: Colors.white),
                      border: InputBorder.none),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.2,
                    right: MediaQuery.of(context).size.width * 0.2),
                width: double.infinity,
                child: RaisedButton.icon(
                  onPressed: () {
                    getUserLocation();
                  },
                  //onPressed: (){},
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                  color: Colors.green,
                  icon: Icon(Icons.location_on),
                  label: Text("Get your location"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadPageUI() {
    return Builder(builder: (BuildContext _context) {
      _auth = Provider.of<AuthProvider>(_context);
      return Container(
        alignment: Alignment.center,
        color: Theme.of(context).accentColor.withOpacity(0.5),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.add_photo_alternate,
              color: Colors.grey,
              size: 100,
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: RaisedButton(
                onPressed: () => takeImage(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.0),
                ),
                child: Text(
                  "Upload Image",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    });
  }

  _removeImage() {
    setState(() {
      _file = null;
    });
  }

  takeImage(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: new Color.fromRGBO(38, 38, 38, 1),
            title: Text(
              "New Post",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  "Capture Image with Camera",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: captureImageWithCamera,
              ),
              SimpleDialogOption(
                child: Text(
                  "Capture Image from Gallery",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: pickImageFromGallery,
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  NavigationService.instance.goBack();
                },
              ),
            ],
          );
        });
  }

  captureImageWithCamera() async {
    NavigationService.instance.goBack();
    File _imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 680,
      maxWidth: 970,
    );
    setState(() {
      this._file = _imageFile;
    });
  }

  pickImageFromGallery() async {
    NavigationService.instance.goBack();
    File _imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 680,
      maxWidth: 970,
    );
    setState(() {
      this._file = _imageFile;
    });
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placeMark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark mPlaceMark = placeMark[0];
    String completeAddressInfo =
        '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, ${mPlaceMark.subLocality} ${mPlaceMark.locality} ,${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea},${mPlaceMark.postalCode} ${mPlaceMark.country},';

    // String specificAddress = '${mPlaceMark.locality},${mPlaceMark.country}';

    locationTextEditingController.text = completeAddressInfo;
  }

  controlUploadAndSave() async {
    setState(() {
      uploading = true;
    });

    await compressingPhoto();

    var result =
        await CloudStorageService.instance.uploadUserImage(posID, _file);

    var _downloadURL = await result.ref.getDownloadURL();

    await DBService.instance.savePostInfoToFirestore(
        _auth.user.uid,
        posID,
        _auth.user.displayName,
        _downloadURL,
        locationTextEditingController.text,
        descriptionTextEditingController.text);

    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    setState(() {
      _file = null;
      uploading = false;
      posID = new Uuid().v1();
    });
  }

  compressingPhoto() async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(_file.readAsBytesSync());
    final compressingImageFile = File('$path/img_$posID.jpg')
      ..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 90));

    setState(() {
      _file = compressingImageFile;
    });
  }
}
