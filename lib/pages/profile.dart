import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codemmunity/models/user.dart';
import 'package:codemmunity/pages/edit_profile.dart';
import 'package:codemmunity/widgets/header.dart';
import 'package:codemmunity/widgets/post.dart';
import 'package:codemmunity/widgets/post_tile.dart';
import 'package:codemmunity/widgets/progress.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'home.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // initialize the default isFollowing value to false.
  bool isFollowing = false;
  // intialize the default post orientation to grid.
  String postOrientation = "grid";
  int followersCount = 0;
  int followingCount = 0;
  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];
  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowersCount();
    getFollowingCount();
    checkIfFollowing();
  }

  // to check if we are following a certain user.
  checkIfFollowing() async {
    // if a document with our id exists in their followers collection then we are following that user.
    // so we get document and see if it exists.
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();
    setState(() {
      // depending whether the doc exists or not we set the value of isFollowing.
      isFollowing = doc.exists;
    });
  }

  getFollowersCount() async {
    // get all the docuemnts from the user's followers collection.
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();
    setState(() {
      // set the count to the length of the documents of the snapshot.
      followersCount = snapshot.documents.length;
    });
  }

  getFollowingCount() async {
    // get all the docuemnts from the user's follwoing collection.
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      // set the count to the length of the documents of the snapshot.
      followingCount = snapshot.documents.length;
    });
  }

  getProfilePosts() async {
    // set the state to loading state.
    setState(() {
      isLoading = true;
    });
    // get all the posts from the post reference based on the profile id of the user in the order with the latest post first.
    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      // after getting the documents set the loading state to false.
      isLoading = false;
      // get the count of the posts by the length of the documents of the snapshot.
      postCount = snapshot.documents.length;
      // Deserialize each document and convert it into a user instance and store it in a list of posts.
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 3.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 235.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.black : Colors.blue,
            border: Border.all(
              color: Colors.white54,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    // if we are viewing our own profile,we have to show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: "Edit Profile",
        function: editProfile,
      );
    }
    // if we are follwing that user show the unfollow button.
    else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnfollowUser,
      );
    }
    // if we aren't following that user then show the follow button. 
    else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        function: handleFollowUser,
      );
    }
  }

  // to handle the unfollow function.

  handleUnfollowUser() {
    // set the state with isFollwing to false as the user is unfollowing the other user.
    setState(() {
      isFollowing = false;
    });
    // if there is a document with our user id in their followers collection then remove it.(remove the follower)
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // if the user exists in our following collection then remove them.(remove from following)
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    // delete the activity feed notification.
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  // to handle the follow function.

  handleFollowUser() {
    // set the state with isFollowing to true as the user is following the other user.
    setState(() {
      isFollowing = true;
    });
    // make auth user follower of another user(add a document with our document id to the follwoers collection of that user.)
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({});
    // put that user to the current user's following collection.
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .setData({});
    // adding a notification to the activity feed of the user that is followed by ther current user.
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .setData({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": currentUser.username,
      "userId": currentUserId,
      "userProfileImage": currentUser.photoUrl,
      "timestamp": DateTime.now(),
    });
  }

  buildProfileHeader() {
    return FutureBuilder(
      // get the user by resolving the future.
      future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        // if the snapshot hasn't loaded data yet,then show the progress indicator.
        if (!snapshot.hasData) return circularProgress();
        // Deserialize ther data and convert the doc snapshot to a User instance.
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 45.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn("Posts", postCount),
                            buildCountColumn("Followers", followersCount-1),
                            buildCountColumn("Following", followingCount),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  user.username,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2.0),
                child: Text(
                  user.bio,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  buildProfilePosts() {
    // if it is in a loading state,then return the progress indicator.
    if (isLoading)
      return circularProgress();
    // if there are no posts then show the no content photo.
    else if (posts.isEmpty) {
      return Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // SvgPicture.asset("assets/images/no_content.svg", height: 260.0),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text("No Posts",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
    // if there are posts and the orientaion is set to grid then show the posts in a grid view.
    else if (postOrientation == "grid") {
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(
          GridTile(
            child: PostTile(post),
          ),
        );
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }
    // if the post orientation is set to list then show the posts by a list view.
    else if (postOrientation == "list") {
      return Column(
        children: posts,
      );
    }
  }

  setPostOrientation(String postOrientation) {
    setState(() {
      this.postOrientation = postOrientation;
    });
  }

  // to toggle between grid view and list view.

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setPostOrientation("grid"),
          icon: Icon(
            Icons.grid_on,
            // if the post orientation is grid then change it's color to orange.
            color: postOrientation == "grid" ? Colors.orange : Colors.blueGrey,
            size: 25.0,
          ),
        ),
        IconButton(
          onPressed: () => setPostOrientation("list"),
          icon: Icon(
            Icons.list,
            // if the post orientation is list then change it's color to orange.
            color: postOrientation == "list" ? Colors.orange : Colors.blueGrey,
            size: 35.0,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: header(titleText: "Profile"),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(
            height: 0.0,
            color: Colors.white38,
          ),
          buildTogglePostOrientation(),
          Divider(
            height: 0.0,
            color: Colors.white38,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
