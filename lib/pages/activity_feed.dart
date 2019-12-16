import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codemmunity/pages/home.dart';
import 'package:codemmunity/pages/post_screen.dart';
import 'package:codemmunity/pages/profile.dart';
import 'package:codemmunity/widgets/header.dart';
import 'package:codemmunity/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {

  // get the activity feed items and store it in a list of ActivityFeedItem.

  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .document(currentUser.id)
        .collection("feedItems")
        .orderBy("timestamp", descending: true)
        .limit(50)
        .getDocuments();
    List<ActivityFeedItem> feedItems = [];
    // For each document stored in snapshot add it to the list.
    snapshot.documents.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    });
    // return the list of the ActivityFeedItem.
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: header(titleText: "Activity Feed"),
      body: Container(
        // future builder will resolve the future and build the activity feed notifications.
        child: FutureBuilder(
          // resolving activity feed.
          future: getActivityFeed(),
          builder: (context, snapshot) {
            // if snapshot doesn't have data yet,return a progress indicator.
            if (!snapshot.hasData) {
              return circularProgress();
            }
            return ListView(
              // create a listview of all the data in the snapshot received after resolving the future.
              children: snapshot.data,
            );
          },
        ),
      ),
    );
  }
}

// A widget that contains the preview of the image of the post regarding to which the notification is in the Activity feed. 
Widget mediaPreview;
// Based on the type of the notification we set a string related to that type. (ex : "started following you.")
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

  // deserialize the data (convert the document snaphot to a  Activity Feed Item instance.)

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


  // method to show the full post based on the post id and user id linked to the post.
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

  // to set the media preview based on the type of the notifcation.

  configureMediaPreview(context) {
    // if the type is like or comment show the image of the post on which the like/comment was made.
    if (type == "like" || type == "comment") {
      mediaPreview = GestureDetector(
        // on tapping the media preview show the full screen version of the post.
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
    }
    // if the type isn't like or comment (ex : follow) then just set the preview to an empty text. 
    else {
      mediaPreview = Text("");
    }

    // set the activityItemText based on the type of the notification.

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
            // show the user's profile when a user taps on the username of another or his own username.
            onTap: () => showProfile(context,profileId : userId),
            // rich text allows us to give style of based on text span.
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
// method to show the profile of the user.
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
