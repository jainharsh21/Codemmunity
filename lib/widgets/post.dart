import 'dart:async';
// import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codemmunity/models/user.dart';
import 'package:codemmunity/pages/comments.dart';
import 'package:codemmunity/pages/home.dart';
import 'package:codemmunity/widgets/custom_image.dart';
import 'package:codemmunity/widgets/progress.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String caption;
  final String mediaUrl;
  final dynamic likes;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.caption,
    this.mediaUrl,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      caption: doc['caption'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes) {
    if (likes == null) return 0;
    int count = 0;
    // if the key is true increment like count;
    likes.values.forEach((val) {
      if (val == true) count += 1;
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        caption: this.caption,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String caption;
  final String mediaUrl;
  int likeCount;
  Map likes;
  bool isLiked;
  bool showLikeAnimation = false;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.caption,
    this.mediaUrl,
    this.likes,
    this.likeCount,
  });

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return circularProgress();
        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => print("user profile displayed"),
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(
            location,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          trailing: IconButton(
            onPressed: () => print("delete post"),
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': false});
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false; 
      });
    }
    else if(!isLiked){
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': true});
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showLikeAnimation = true;
      });
      Timer(
        Duration(milliseconds: 500),
        (){
          setState(() {
            showLikeAnimation =false;
          });
        }
      );
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl),
          showLikeAnimation ? Icon(Icons.thumb_up,size: 80.0,color: Colors.blue,) : Text(""),
        ],
      ),
    );
  }

  

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
            ),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                Icons.thumb_up,
                size: 28.0,
                color: isLiked ? Colors.orange : Colors.blueGrey,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 40.0, right: 20.0),
            ),
            GestureDetector(
              onTap: () => showComments(
                              context,
                              postId : postId,
                              ownerId : ownerId,
                              mediaUrl : mediaUrl,
                            ),
                            child: Icon(
                              Icons.mode_comment,
                              size: 28.0,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 20.0),
                            child: Text(
                              "$likeCount likes",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 20.0),
                            child: Text(
                              "$username  ",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              caption,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: <Widget>[
                      //     Container(
                      //       margin: EdgeInsets.only(left: 20.0),
                      //       child: Text(timeago.format(timestamp),style: TextStyle(color: Colors.white),),
                      //     ),
                      //   ],
                      // ),
                    ],
                  );
                }
              
                @override
                Widget build(BuildContext context) {
                  isLiked = (likes[currentUserId]==true);    
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      buildPostHeader(),
                      buildPostImage(),
                      buildPostFooter(),
                    ],
                  );
                }
              
                showComments(BuildContext context, {String postId, String ownerId, String mediaUrl}) {
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return Comments(
                      postId : postId,
                      postOwnerId : ownerId,
                      postMediaUrl : mediaUrl,
                    );
                  }));
                }
}
