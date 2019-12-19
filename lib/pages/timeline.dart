import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codemmunity/models/user.dart';
import 'package:codemmunity/widgets/header.dart';
import 'package:codemmunity/widgets/post.dart';
import 'package:codemmunity/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class Timeline extends StatefulWidget {
  final User currentUser;
  Timeline({this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;
  @override
  void initState() {
    super.initState();
    getTimeline();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Text("No Posts", style: TextStyle(color: Colors.white));
    } else {
      return ListView(children: posts);
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: header(isAppTitle: true),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}
