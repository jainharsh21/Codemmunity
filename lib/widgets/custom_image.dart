import 'package:cached_network_image/cached_network_image.dart';
import 'package:codemmunity/widgets/progress.dart';
import 'package:flutter/material.dart';

Widget cachedNetworkImage(mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    placeholder: (context,url)=>Padding(
      child: circularProgress(),
      padding: EdgeInsets.all(20.0),
    ),
    errorWidget: (context,url,error)=>Icon(Icons.error),
  );
}
