import 'package:flutter/material.dart';

AppBar header(context,
    {bool isAppTitle=false, String title, disableBackbutton = false}) {
  return AppBar(
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    automaticallyImplyLeading: disableBackbutton ? false : true,
    title: Text(
      isAppTitle ? "Instagram" : title,
      style: TextStyle(
        color: Colors.white,
        fontSize: isAppTitle ? 30 : 20,
        fontFamily: isAppTitle ? "Dancing Script" : "",
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
