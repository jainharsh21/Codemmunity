import 'package:flutter/material.dart';

// Custom header created which can be used accross differnet pages.

AppBar header({bool isAppTitle = false,String titleText}) {
  return AppBar( 
    automaticallyImplyLeading: true,
    title: Text(
      isAppTitle ?  "Codemmunity" : titleText,
        style: TextStyle(
            color: Colors.white,
            fontFamily: isAppTitle ?  'Signatra' : '',
            fontSize: isAppTitle ?  35.0 : 20.0,
            ),
            overflow: TextOverflow.ellipsis,
            ),
    backgroundColor: Colors.black,
    centerTitle: true,
  );
}
