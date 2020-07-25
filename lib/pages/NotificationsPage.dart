import 'package:flutter/material.dart';
import 'package:my_instagram/widgets/HeaderWidget.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: "Notifications"),
    );
  }
}
