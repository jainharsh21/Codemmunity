import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codemmunity/models/user.dart';
import 'package:codemmunity/pages/home.dart';
import 'package:codemmunity/pages/profile.dart';
import 'package:codemmunity/widgets/progress.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin<Search>{
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  handleSearch(String query) {
    // Search the user by their username by running a query.
    Future<QuerySnapshot> users = usersRef
        .where("username", isGreaterThanOrEqualTo: query.toLowerCase())
        .getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.black,
      title: TextFormField(
        controller: searchController,
        style: TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: "Search For A User....",
          hintStyle: TextStyle(color: Colors.grey),
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28.0,
            color: Colors.blueGrey,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
            color: Colors.blueGrey,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Container buildNoContent() {
    // Make the screen responisve with rotation.
    // final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            // SvgPicture.asset(
            //   'assets/images/search.svg', 
            //   height: orientation == Orientation.portrait ? 300.0 : 200.0,
            //   placeholderBuilder: (BuildContext context){
            //     return circularProgress();
            //   }
            // ),
            Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontStyle: FontStyle.italic,
                  fontSize: 50.0),
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        // if the search results are not laoded show the progress indicator.
        if (!snapshot.hasData) return circularProgress();
        List<UserResult> searchResults = [];
        // for each document in the snapshot's data create a corresponding user
        // instance and build it's UserResult instance which will be displayed on the screen.
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });
        // Return the listview of the list of UserResults.
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildSearchField(),
      body:
          // If search results is null build no content screen or else build search results screen.
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context,profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                radius: 27.5,
                backgroundColor: Colors.blueGrey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.blueGrey,
          ),
        ],
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
