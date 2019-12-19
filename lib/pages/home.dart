import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codemmunity/models/user.dart';
import 'package:codemmunity/pages/activity_feed.dart';
import 'package:codemmunity/pages/create_account.dart';
import 'package:codemmunity/pages/profile.dart';
import 'package:codemmunity/pages/search.dart';
import 'package:codemmunity/pages/timeline.dart';
import 'package:codemmunity/pages/upload.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final commentsRef = Firestore.instance.collection('comments');
final activityFeedRef = Firestore.instance.collection('feed');
final followersRef = Firestore.instance.collection('followers');
final followingRef = Firestore.instance.collection('following');
final timelineRef = Firestore.instance.collection('timeline');
final DateTime timestamp = DateTime.now();
User currentUser;
final StorageReference storageRef = FirebaseStorage.instance.ref();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // initializing the isAuth to false as by default the user would not be authenticated.
  bool isAuth = false;
  // pagecontroller to naviagte between the pages on the nav bar.
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    // set the page controller.
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignin(account);
    }, onError: (err) {
      print('Error signing in : $err');
    });

    // If the user is already signed in,redirect him to the main page instead of the sign-in page.
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignin(account);
    }).catchError((err) {
      print('Error signing in : $err');
    });
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  // When the page is changed,update the pageIndex to the current page index.
  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  // Change the page when clicked on the respective icon from the navigation bar.
  onTapNav(int pageIndex) {
    // can use jumpToPage if animation not needed.
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.bounceInOut,
    );
  }

  // function to handle the sign in.
  handleSignin(GoogleSignInAccount account) {
    // if the account is not null the create the user is firestore.
    if (account != null) {
      createUserInFirestore();
      // print('User signed in! : $account');
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.document(user.id).get();

    if (!doc.exists) {
      // 2) if the user doesn't exist, then we want to take them to the create account page
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from create account, use it to make new user document in users collection
      usersRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp,
      });
      // Update the doc variable after getting the newly added data.
      doc = await usersRef.document(user.id).get();
    }

    // Convert the document into a User instance.
    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.username);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(currentUser : currentUser),
          ActivityFeed(),
          Upload(currentUser : currentUser),
          Search(),
          Profile(profileId:currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.black,
        currentIndex: pageIndex,
        onTap: onTapNav,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 40.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
              Colors.blue,
              Colors.black,
            ])),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Codemmunity',
              style: TextStyle(
                  fontFamily: "Signatra", fontSize: 75.0, color: Colors.white),
            ),
            GestureDetector(
              // onTap: ()=>print("sign in tapped"),
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If the user is authenticated take him to the main page,if not take the user to the sign-in page.
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
