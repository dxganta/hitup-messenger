import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageFullScreen extends StatelessWidget {
  final String url;
  final String tag;
  final String memoryImage;
  ImageFullScreen({this.url, this.tag, this.memoryImage});

  Widget _buildImage() {
    if (memoryImage != null) {
      return Image(
        image: MemoryImage(base64Decode(memoryImage)),
      );
    } else {
      return tag != null
          ? Hero(tag: tag, child: CachedNetworkImage(imageUrl: url))
          : CachedNetworkImage(
              imageUrl: url,
            );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: _buildImage(),
    );
  }
}
