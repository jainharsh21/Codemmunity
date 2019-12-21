import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:codemmunity/models/user.dart';
import 'package:codemmunity/pages/home.dart';
import 'package:codemmunity/widgets/progress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';

class Upload extends StatefulWidget {
  final User currentUser;
  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> with AutomaticKeepAliveClientMixin<Upload>{
  TextEditingController locationContoller = TextEditingController();
  TextEditingController captionController = TextEditingController();
  File file;
  bool isUploading = false;
  String postId = Uuid().v4();
  handleTakePhoto() async {
    // to take the photo from the camera.
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 900,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

// To take the photo from the phone's gallery.
  handleImageFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: Colors.black,
            elevation: 45.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            title: Text(
              "Create Post",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  "Photo With Camera",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text(
                  "Image From Gallery",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: handleImageFromGallery,
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  Container uploadScreen() {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset("assets/images/upload.svg", height: 260.0,
              placeholderBuilder: (BuildContext context) {
            return circularProgress();
          }),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text("Upload Image",
                    style: TextStyle(color: Colors.white, fontSize: 22.0)),
                color: Colors.deepOrange,
                onPressed: () => selectImage(context)),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    // get the directory
    final tempDir = await getTemporaryDirectory();
    // get its path
    final path = tempDir.path;
    // store the image uploaded.
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    // compress the image and store it in a new file.
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    // Set the state with the new compressed file.
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore({String mediaUrl, String location, String caption}) {
    postsRef
        .document(widget.currentUser.id)
        .collection("userPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
      "caption": caption,
      "location": location,
      "timestamp": DateTime.now(),
      "likes": {},
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationContoller.text,
      caption: captionController.text,
    );
    captionController.clear();
    locationContoller.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  getUserLocation() async {
    print("tapped");
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    print(completeAddress);
    String formattedAddress = "${placemark.locality}, ${placemark.country}";
    print(formattedAddress);
    locationContoller.text = formattedAddress;
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 28.0,
          ),
          onPressed: clearImage,
        ),
        title: Text(
          "Upload Post",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text(
              "Post",
              style: TextStyle(color: Colors.blue, fontSize: 20.0),
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            // height: 500.0,
            padding: EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: Image.file(file),
            ),
          ),
          // Image.file(file),
          // Container(
          //   width: MediaQuery.of(context).size.width * 0.8,
          //   child: Center(
          //     child: AspectRatio(
          //       aspectRatio: 16 / 9,
          //       child: Container(
          //         child: Image.file(file),
          //       ),
          //     ),
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write A Caption....",
                  hintStyle: TextStyle(
                    color: Colors.blueGrey,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.white54,
          ),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: locationContoller,
                decoration: InputDecoration(
                  hintText: "Add The Location....",
                  hintStyle: TextStyle(
                    color: Colors.blueGrey,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              label: Text(
                "Use Current Location",
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.blue,
              onPressed: getUserLocation,
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return file == null ? uploadScreen() : buildUploadForm();
  }
}
