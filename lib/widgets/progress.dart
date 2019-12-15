import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Loading Progress bar.

Container circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top:10.0),
    child: SpinKitThreeBounce(
      size: 30.0,
      color: Colors.blue,
    ),
    // child : CircularProgressIndicator(
    //   valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
    // ),
  );
}

Container linearProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
      backgroundColor: Colors.black,
      valueColor: AlwaysStoppedAnimation(Colors.blue[900]),
    ),
  );
}
