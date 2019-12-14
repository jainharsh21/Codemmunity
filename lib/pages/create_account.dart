import 'dart:async';

import 'package:codemmunity/widgets/header.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username;

  submit() {
    final form = _formKey.currentState;
    // If the form is validated then save it and display a snackbar welcoming the user.
    if (form.validate()) {
      form.save();
      SnackBar snackBar = SnackBar(
        content: Text("Welcome $username"),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      // Added a time so that the user can see the welcome message and the navigation is delayed.
      Timer(Duration(seconds: 2), () {
        // pop the username so that it can be used in differnt functions/pages.
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(titleText: "Set Up Your Profile"),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text("Create A Username ",
                        style: TextStyle(fontSize: 25.0)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      autovalidate: true,
                      key: _formKey,
                      child: TextFormField(
                        validator: (val) {
                          if (val.trim().length < 3 || val.isEmpty)
                            return "Username Too Short";
                          else if (val.trim().length > 30)
                            return "Username Too Long";
                          else
                            return null;
                        },
                        onSaved: (val) => username = val.toLowerCase(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: "Must Be At Least 3 Characters",
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
