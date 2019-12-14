import 'package:codemmunity/widgets/custom_image.dart';
import 'package:codemmunity/widgets/post.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final Post post;  
  PostTile(this.post);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>print("full screen"),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
