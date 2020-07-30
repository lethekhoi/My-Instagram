import 'package:flutter/material.dart';
import 'package:my_instagram/models/post.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  displayFullPost(context) {
    //Navigator.push(context, MaterialPageRoute(builder: (context)=>PostScreenPage(postId: post.postId, userId: post.ownerId)));
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
