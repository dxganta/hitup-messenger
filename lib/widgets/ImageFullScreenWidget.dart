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
    return Stack(
      children: [
        Positioned(
          left: 12.0,
          top: 10.0,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 40.0,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            color: Colors.black,
            child: _buildImage(),
          ),
        ),
      ],
    );
  }
}
