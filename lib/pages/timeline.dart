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
      return ListView(  children: posts);
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

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:codemmunity/widgets/header.dart';
// import 'package:codemmunity/widgets/progress.dart';
// // import 'package:codemmunity/widgets/progress.dart';
// import 'package:flutter/material.dart';

// final CollectionReference usersRef = Firestore.instance.collection('users');

// class Timeline extends StatefulWidget {
//   @override
//   _TimelineState createState() => _TimelineState();
// }

// class _TimelineState extends State<Timeline> {
//   @override
//   void initState() {
//     // getUserById();
//     // createUser();
//     // updateUser();
//     deleteUser();
//     super.initState();
//   }

//   createUser() {
//     usersRef
//         .document("adsadsadsadsad")
//         .setData({"username": "Ipsum", "postsCount": 0, "isAdmin": false});
//   }

//   updateUser() async{
//     final doc = await usersRef
//         .document("B0zxpceEFUpn5GEL5aIc").get();

//     if(doc.exists){
//       doc.reference.updateData({"username": "Ipsum", "postsCount": 0, "isAdmin": false});
//     }

//         // .updateData({
//         //   "username": "Doremi", "postsCount": 0, "isAdmin": false
//         // });
//   }

//   deleteUser() async{
//     final doc = await usersRef
//         .document("B0zxpceEFUpn5GEL5aIc")
//         .get();
//     if(doc.exists)
//     {
//       doc.reference.delete();
//     }
//   }

//   // getUserById() async
//   // {
//   //   final String id = 'Y9sm75DjyLB1M0p8urvw';
//   //   DocumentSnapshot doc = await usersRef.document(id).get();
//   //       print(doc.data);
//   //       print(doc.documentID);
//   //       print(doc.exists);
//   // }

//   @override
//   Widget build(context) {
//     return Scaffold(
//       appBar: header(isAppTitle: true),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: usersRef.snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return circularProgress();
//           }
//           final List<Text> children = snapshot.data.documents
//               .map((doc) => Text(doc['username']))
//               .toList();
//           return Container(
//             child: ListView(
//               children: children,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
