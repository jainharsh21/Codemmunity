import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codemmunity/pages/home.dart';
import 'package:codemmunity/widgets/header.dart';
import 'package:codemmunity/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

// first create a 'comment' model.

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  @override
  CommentsState createState() => CommentsState(
        postId: this.postId,
        postOwnerId: this.postOwnerId,
        postMediaUrl: this.postMediaUrl,
      );
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  CommentsState({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  buildComments() {
    return StreamBuilder(
      // used a steam builder to update the comments in real-time.
      stream: commentsRef
          .document(postId)
          .collection('comments')
          // show the latest comments at the top.
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // if the snapshot doesn't have any data yet,return progress indicator.
        if (!snapshot.hasData)
          return circularProgress();
        // if the data is loaded then create a list and add each document from the snapshot to the list of comments.
        List<Comment> comments = [];
        snapshot.data.documents.forEach((doc){
          comments.add(Comment.fromDocument(doc));
        });
        // return a list view containing the children as the list of comments.
        return ListView(
          children: comments,
        );
      },);
  }

  //add all the properties of the comment to the firestore collection of 'comments'. 
  addComment() {
    commentsRef.document(postId).collection("comments").add({
      "username": currentUser.username,
      "comment": commentController.text,
      "timestamp": DateTime.now(),
      "avatarUrl": currentUser.photoUrl,
      "userId": currentUser.id,
    });

    // check whether the current user is the post owner or not.

    bool isNotPostOwner =  postOwnerId!=currentUser.id;
    // if the current user is not the post owner then only show it's notification.  
    if(isNotPostOwner){
      activityFeedRef.document(postOwnerId).collection("feedItems").add({
        "type": "comment",
        "commentData" : commentController.text,
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImage": currentUser.photoUrl,
        "postId": postId,
        "mediaUrl": postMediaUrl,
        "timestamp": DateTime.now(),
    });
    } 
    // clear the text of the comment controller once the comment is submitted.
    commentController.clear(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: header(titleText: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              style: TextStyle(color: Colors.white),
              controller: commentController,
              decoration: InputDecoration(
                labelText: "Write a comment",
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: Text(
                "Post",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comment,
    this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      avatarUrl: doc['avatarUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
              comment,
              style: TextStyle(color: Colors.white),
            ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl), 
          ),
          subtitle: Text(timeago.format(timestamp.toDate()),style: TextStyle(color: Colors.white),),
        ),
        Divider(
          // color: Colors.white54,
        ),
      ],
    );
  }
}
