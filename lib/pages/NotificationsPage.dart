import 'package:flutter/material.dart';
import 'package:my_instagram/models/notifications_item.dart';
import 'package:my_instagram/models/post.dart';
import 'package:my_instagram/pages/CommentsPage.dart';
import 'package:my_instagram/pages/PostScreenPage.dart';
import 'package:my_instagram/pages/ProfilePage.dart';
import 'package:my_instagram/providers/google_sign_in_provider.dart';
import 'package:my_instagram/services/db_service.dart';
import 'package:my_instagram/services/navigation_service.dart';
import 'package:my_instagram/widgets/HeaderWidget.dart';
import 'package:my_instagram/widgets/ProgressWidget.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  AuthProvider _auth;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, title: "Notifications", disableBackbutton: true),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: notificationPageUI(),
      ),
    );
  }

  notificationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return _auth.user.uid != null
            ? StreamBuilder<List<NotificationsItem>>(
                stream: DBService.instance.getNotificationsItem(_auth.user.uid),
                builder: (BuildContext _context, _snapshot) {
                  var _notificationItemData = _snapshot.data;
                  if (_snapshot.hasData) {
                    if (_notificationItemData.length != 0) {
                      return ListView.builder(
                        itemCount: _notificationItemData.length,
                        itemBuilder: (BuildContext _context, int _index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: GestureDetector(
                              onTap: () {
                                onTapMedia(_notificationItemData[_index]);
                              },
                              child: ListTile(
                                title: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style: TextStyle(
                                        fontSize: 14.0, color: Colors.white),
                                    children: [
                                      TextSpan(
                                          text: _notificationItemData[_index]
                                                  .username +
                                              " ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text: configureMediaText(
                                              _notificationItemData[_index]),
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.lightBlueAccent,
                                  backgroundImage: NetworkImage(
                                      _notificationItemData[_index]
                                          .userProfileImg),
                                ),
                                subtitle: Text(
                                  timeago.format(_notificationItemData[_index]
                                      .timestamp
                                      .toDate()),
                                  style: TextStyle(color: Colors.white70),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: configureMediaPreview(
                                    _notificationItemData[_index]),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Container(
                        height: 0,
                        width: 0,
                      );
                    }
                  } else {
                    return Container(
                      height: 0,
                      width: 0,
                    );
                  }
                })
            : circularProgress();
      },
    );
  }

  configureMediaPreview(NotificationsItem notificationsItem) {
    if (notificationsItem.type == "like" ||
        notificationsItem.type == "comment") {
      return Container(
        height: 45.0,
        width: 45.0,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(notificationsItem.url)),
            ),
          ),
        ),
      );
    } else if (notificationsItem.type == "follow") {
      return Text("");
    }
  }

  configureMediaText(NotificationsItem notificationsItem) {
    if (notificationsItem.type == "like") {
      return "liked your post.";
    } else if (notificationsItem.type == "comment") {
      return "commented: ${notificationsItem.commentData}";
    } else if (notificationsItem.type == "follow") {
      return "started following you.";
    } else {
      return "Error, Unknown type = ${notificationsItem.type}";
    }
  }

  onTapMedia(NotificationsItem notificationsItem) async {
    if (notificationsItem.type == "like") {
      Post post = await DBService.instance
          .getPostInfo(_auth.user.uid, notificationsItem.postID);
      return NavigationService.instance.navigateToRoute(
        MaterialPageRoute(
          builder: (BuildContext _context) {
            return PostScreenPage(post: post);
          },
        ),
      );
    }
    if (notificationsItem.type == "comment") {
      Post post = await DBService.instance
          .getPostInfo(_auth.user.uid, notificationsItem.postID);
      return NavigationService.instance.navigateToRoute(
        MaterialPageRoute(
          builder: (BuildContext _context) {
            return CommentsPage(post: post);
          },
        ),
      );
    }
    if (notificationsItem.type == "follow") {
      return NavigationService.instance.navigateToRoute(
        MaterialPageRoute(
          builder: (BuildContext _context) {
            return ProfilePage(
                currentUserID: _auth.user.uid,
                userProfileID: notificationsItem.userID);
          },
        ),
      );
    }
  }
}
