import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_allamo/theme/constant.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;

  const ImageViewerScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final List<int> decoded = base64Decode(imageUrl);
    final String decodedImageUrl = utf8.decode(decoded);
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        title: const Text('Image Viewer',
            style: TextStyle(color: textColor, fontSize: 17)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: appBarColor,
      ),
      body: Center(
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(decodedImageUrl),
          backgroundDecoration: const BoxDecoration(color: scaffoldColor),
        ),
      ),
    );
  }
}
