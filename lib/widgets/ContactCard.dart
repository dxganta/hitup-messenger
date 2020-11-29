import 'package:cached_network_image/cached_network_image.dart';
import 'package:coocoo/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class ContactCard extends StatelessWidget {
  final String name;
  final String status;
  final String profilePic;
  final parser = EmojiParser();

  ContactCard({
    @required this.name,
    @required this.profilePic,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        radius: (screenWidth / perfectWidth) * 18.0,
        backgroundImage: CachedNetworkImageProvider(profilePic),
      ),
      title: Text(
        parser.emojify(name),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: (screenWidth / perfectWidth) * 17.0,
        ),
      ),
      subtitle: Text(
        status,
        style: TextStyle(
          fontSize: (screenWidth / perfectWidth) * 14.0,
        ),
      ),
    );
  }
}
