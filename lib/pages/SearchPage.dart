import 'package:flutter/material.dart';
import 'package:my_instagram/widgets/HeaderWidget.dart';
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: "Search"),
      
    );
  }
}