import 'package:cloud_firestore/cloud_firestore.dart';

// To convert the Document Snapshot into a user instance,which can be used across different pages.
class User {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;

// User constructor to initalize all the fields.
  User({
    this.id,
    this.username,
    this.email,
    this.photoUrl,
    this.displayName,
    this.bio,
  });

// function that bulds the user instance from doc snapshot. 
  factory User.fromDocument(DocumentSnapshot doc){
    return User(
      id: doc['id'],
      username: doc['username'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio'],
    );
  }



}


