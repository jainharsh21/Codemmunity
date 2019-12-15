import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codemmunity/pages/home.dart';
import 'package:codemmunity/pages/post_screen.dart';
import 'package:codemmunity/pages/profile.dart';
import 'package:codemmunity/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .document(currentUser.id)
        .collection("feedItems")
        .orderBy("timestamp", descending: true)
        .limit(50)
        .getDocuments();
    List<ActivityFeedItem> feedItems = [];

    snapshot.documents.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    });

    // snapshot.documents.forEach((doc) {
    //   print("Activity Feed Item : ${doc.data}");
    // });

    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: header(titleText: "Activity Feed"),
      body: Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SpinKitThreeBounce(
                size: 30.0,
                color: Colors.black,
              );
            }
            return ListView(
              children: snapshot.data,
            );
          },
        ),
      ),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String commentData;
  final String mediaUrl;
  final String postId;
  final Timestamp timestamp;
  final String type;
  final String userId;
  final String userProfileImage;
  final String username;

  ActivityFeedItem({
    this.commentData,
    this.mediaUrl,
    this.postId,
    this.timestamp,
    this.type,
    this.userId,
    this.userProfileImage,
    this.username,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      commentData: doc['commentData'],
      mediaUrl: doc['mediaUrl'],
      postId: doc['postId'],
      timestamp: doc['timestamp'],
      type: doc['type'],
      userId: doc['userId'],
      userProfileImage: doc['userProfileImage'],
      username: doc['username'],
    );
  }

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: postId,
          userId: userId,
        ),
      ),
    );
  }

  configureMediaPreview(context) {
    if (type == "like" || type == "comment") {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(mediaUrl),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }

    if (type == "like") {
      activityItemText = "liked your post.";
    } else if (type == "follow") {
      activityItemText = "started following you.";
    } else if (type == "comment") {
      activityItemText = "commented : $commentData";
    } else {
      activityItemText = 'Error : Unknownk type $type ';
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context,profileId : userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' $activityItemText',
                  ),
                ],
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImage),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white54,
            ),
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
      ),
    ),
  );
}
