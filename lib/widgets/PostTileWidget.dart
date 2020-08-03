import 'package:flutter/material.dart';
import 'package:my_instagram/models/post.dart';
import 'package:my_instagram/pages/PostScreenPage.dart';
import 'package:my_instagram/services/navigation_service.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  displayFullPost(context) {
    NavigationService.instance.navigateToRoute(
      MaterialPageRoute(
        builder: (BuildContext _context) {
          return PostScreenPage(
            post: this.post,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: GestureDetector(
        onTap: () => displayFullPost(context),
        child: Image.network(post.url),
      ),
    );
  }
}
