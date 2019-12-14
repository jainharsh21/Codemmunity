import 'package:flutter/material.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  Widget build(context) {
    return Text("Timeline");
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
