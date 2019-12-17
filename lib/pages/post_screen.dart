import 'package:codemmunity/pages/home.dart';
import 'package:codemmunity/widgets/header.dart';
import 'package:codemmunity/widgets/post.dart';
import 'package:codemmunity/widgets/progress.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {

  final String userId;
  final String postId;

  PostScreen({
    this.postId,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // get the post by resolving the future.
      future: postsRef.document(userId).collection('userPosts').document(postId).get(),
      builder: (context,snapshot){
      // if the snapshot received from resolving the future doesn't have data yet , show the progress indicator.
        if(!snapshot.hasData)
          return circularProgress();
      // Deserialize the snapshot and create a Post instance.
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            backgroundColor: Colors.black ,
            appBar: header(titleText: post.caption),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
